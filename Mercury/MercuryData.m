//
//  MercuryData.m
//  Mercury
//
//  Created by Axel Rivera on 2/22/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "MercuryData.h"

@implementation MercuryData

- (instancetype)init
{
    self = [super init];
    if (self) {
        _watchlist = [@[] mutableCopy];
        _myPositions = [@[] mutableCopy];
        
        [_watchlist addObject:[HGTicker tickerWithType:HGTickerTypeWatchlist symbol:@"RPG"]];
        [_watchlist addObject:[HGTicker tickerWithType:HGTickerTypeWatchlist symbol:@"OBEGX"]];
        [_watchlist addObject:[HGTicker tickerWithType:HGTickerTypeWatchlist symbol:@"SPY"]];
        
        [_myPositions addObject:[HGTicker tickerWithType:HGTickerTypeMyPositions symbol:@"JSVAX"]];
        [_myPositions addObject:[HGTicker tickerWithType:HGTickerTypeMyPositions symbol:@"SWLSX"]];
    }
    return self;
}

- (void)fetchWatchlistWithCompletion:(HGPositionsCompletionBlock)completion
{
    NSMutableArray *symbols = [@[] mutableCopy];
    for (HGTicker *ticker in self.watchlist) {
        [symbols addObject:ticker.symbol];
    }

    [[YahooAPIClient sharedClient] fetchPositionsForSymbols:symbols completion:^(NSArray *positions, NSError *error) {
        if (error) {
            if (completion) {
                completion(nil, error);
            }
            return;
        }

        for (HGTicker *ticker in self.watchlist) {
            for (HGPosition *position in positions) {
                if ([[ticker.symbol uppercaseString] isEqualToString:[position.symbol uppercaseString]]) {
                    ticker.position = position;
                    break;
                }
            }
        }
        
        if (completion) {
            completion(self.watchlist, nil);
        }
    }];
}

- (void)fetchMyPositionsWithCompletion:(HGPositionsCompletionBlock)completion
{
    NSMutableArray *symbols = [@[] mutableCopy];
    for (HGTicker *ticker in self.myPositions) {
        [symbols addObject:ticker.symbol];
    }

    [[YahooAPIClient sharedClient] fetchPositionsForSymbols:symbols completion:^(NSArray *positions, NSError *error) {
        if (error) {
            if (completion) {
                completion(nil, error);
            }
            return;
        }
        
        for (HGTicker *ticker in self.myPositions) {
            for (HGPosition *position in positions) {
                if ([[ticker.symbol uppercaseString] isEqualToString:[position.symbol uppercaseString]]) {
                    ticker.position = position;
                    break;
                }
            }
        }

        if (completion) {
            completion(self.myPositions, nil);
        }
    }];
}

- (void)fetchHistoricalDataForSymbol:(NSString *)symbol completion:(HGHistoricalDataCompletionBlock)completion
{
    NSDate *today = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:today];
    [components setHour:0];
    NSDate *todayAtMidnight = [calendar dateFromComponents:components];
    
    NSDate *startDate = [todayAtMidnight dateByAddingTimeInterval:-kHistoricalStartDateInSecods];
    
    DLog(@"Start Date: %@", startDate);
    DLog(@"End Date: %@", todayAtMidnight)
    
    [[YahooAPIClient sharedClient] fetchHistoricalDataForSymbol:symbol start:startDate end:todayAtMidnight period:@"d"
                                                     completion:^(NSArray *historicalData, NSError *error)
     {
         if (completion) {
             completion(historicalData, error);
         }
     }];
}

- (BOOL)isSymbolPresentInMyPositions:(NSString *)symbol
{
    BOOL present = NO;
    for (HGTicker *ticker in self.myPositions) {
        if ([[symbol uppercaseString] isEqualToString:[ticker.symbol uppercaseString]]) {
            present = YES;
            break;
        }
    }
    return present;
}

- (void)removePositionWithSymbol:(NSString *)symbol
{
    HGTicker *removedTicker = nil;
    for (NSInteger i = 0; i < [self.myPositions count]; i++) {
        HGTicker *ticker = self.myPositions[i];
        if ([[ticker.symbol uppercaseString] isEqualToString:[symbol uppercaseString]]) {
            removedTicker = ticker;
            [self.myPositions removeObjectAtIndex:i];
            break;
        }
    }

    if (removedTicker) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ReloadMyPositionsNotification
                                                            object:nil
                                                          userInfo:@{ @"myPositionRemoved" : removedTicker }];
    }
}

#pragma mark - Singleton Methods

+ (instancetype)sharedData
{
    static MercuryData *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[[self class] alloc] init];
    });
    return _sharedInstance;
}

@end

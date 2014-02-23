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
        
        [_watchlist addObject:@"RPG"];
        [_watchlist addObject:@"OBEGX"];
        [_watchlist addObject:@"SPY"];
        
        [_myPositions addObject:@"JSVAX"];
        [_myPositions addObject:@"SWLSX"];
    }
    return self;
}

- (void)fetchWatchlistWithCompletion:(HGPositionsCompletionBlock)completion
{
    [[YahooAPIClient sharedClient] fetchPositionsForSymbols:self.watchlist completion:^(NSArray *positions, NSError *error) {
        if (error) {
            if (completion) {
                completion(nil, error);
            }
            return;
        }
        
        if (completion) {
            completion(positions, nil);
        }
    }];
}

- (void)fetchMyPositionsWithCompletion:(HGPositionsCompletionBlock)completion
{
    [[YahooAPIClient sharedClient] fetchPositionsForSymbols:self.myPositions completion:^(NSArray *positions, NSError *error) {
        if (error) {
            if (completion) {
                completion(nil, error);
            }
            return;
        }
        
        if (completion) {
            completion(positions, nil);
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

//
//  MercuryData.m
//  Mercury
//
//  Created by Axel Rivera on 2/22/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "MercuryData.h"

#import "NSString+Yahoo.h"

@implementation MercuryData

- (instancetype)init
{
    self = [super init];
    if (self) {
        _watchlist = [@[] mutableCopy];
        _myPositions = [@[] mutableCopy];
        _fetchingWatchlist = NO;
        _fetchingMyPositions = NO;
        
        [_watchlist addObject:[HGTicker tickerWithType:HGTickerTypeWatchlist symbol:@"RPG"]];
        [_watchlist addObject:[HGTicker tickerWithType:HGTickerTypeWatchlist symbol:@"OBEGX"]];
        [_watchlist addObject:[HGTicker tickerWithType:HGTickerTypeWatchlist symbol:@"SPY"]];
        
        [_myPositions addObject:[HGTicker tickerWithType:HGTickerTypeMyPositions symbol:@"JSVAX"]];
        [_myPositions addObject:[HGTicker tickerWithType:HGTickerTypeMyPositions symbol:@"SWLSX"]];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        NSArray *watchlist = [coder decodeObjectForKey:@"MercuryDataWatchlist"];
        NSArray *myPositions = [coder decodeObjectForKey:@"MercuryDataMyPositions"];
        
        self.watchlist = IsEmpty(watchlist) ? [@[] mutableCopy] : [[NSMutableArray alloc] initWithArray:watchlist];
        self.myPositions = IsEmpty(myPositions) ? [@[] mutableCopy] : [[NSMutableArray alloc] initWithArray:myPositions];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.watchlist forKey:@"MercuryDataWatchlist"];
    [coder encodeObject:self.myPositions forKey:@"MercuryDataMyPositions"];
}

- (void)fetchAllPositionsWithCompletion:(HGAllPositionsCompletionBlock)completion
{
    self.fetchingWatchlist = YES;
    self.fetchingMyPositions = YES;
    
    NSMutableArray *symbols = [@[] mutableCopy];
    
    for (HGTicker *ticker in self.watchlist) {
        [symbols addObject:ticker.symbol];
    }
    
    for (HGTicker *ticker in self.myPositions) {
        [symbols addObject:ticker.symbol];
    }
    
    NSSet *symbolsSet = [NSSet setWithArray:symbols];
    
    [[YahooAPIClient sharedClient] fetchPositionsForSymbols:[symbolsSet allObjects] completion:^(NSString *positionsData, NSError *error) {
        self.fetchingWatchlist = NO;
        self.fetchingMyPositions = NO;
        
        if (error) {
            if (completion) {
                completion(nil, nil, error);
            }
            return;
        }
        
        dispatch_queue_t backgroundQueue = dispatch_queue_create("me.axelrivera.queue", NULL);
        dispatch_async(backgroundQueue, ^{
            NSArray *quotesRaw = [positionsData hg_arrayOfQuoteDictionaries];
            DLog(@"%@", quotesRaw);
            
            NSMutableArray *positions = [@[] mutableCopy];
            
            for (NSDictionary *dictionary in quotesRaw) {
                HGPosition *position = [[HGPosition alloc] initWithDictionary:dictionary];
                [positions addObject:position];
            }
            
            DLog(@"positions: %@", positions);
            
            for (HGTicker *ticker in self.watchlist) {
                for (HGPosition *position in positions) {
                    if ([[ticker.symbol uppercaseString] isEqualToString:[position.symbol uppercaseString]]) {
                        ticker.position = position;
                        break;
                    }
                }
            }
            
            for (HGTicker *ticker in self.myPositions) {
                for (HGPosition *position in positions) {
                    if ([[ticker.symbol uppercaseString] isEqualToString:[position.symbol uppercaseString]]) {
                        ticker.position = position;
                        break;
                    }
                }
            }
            
            NSDictionary *userInfo = @{ @"myPositions" : self.myPositions, @"watchlist" : self.watchlist };
            [[NSNotificationCenter defaultCenter] postNotificationName:AllPositionsReloadedNotification
                                                                object:nil
                                                              userInfo:userInfo];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(self.watchlist, self.myPositions, nil);
                }
            });
        });
    }];
}

- (void)fetchWatchlistWithCompletion:(HGTickersCompletionBlock)completion
{
    self.fetchingWatchlist = YES;
    
    NSMutableArray *symbols = [@[] mutableCopy];
    for (HGTicker *ticker in self.watchlist) {
        [symbols addObject:ticker.symbol];
    }

    [[YahooAPIClient sharedClient] fetchPositionsForSymbols:symbols completion:^(NSString *positionsData, NSError *error) {
        self.fetchingWatchlist = NO;
        
        if (error) {
            if (completion) {
                completion(nil, error);
            }
            return;
        }
        
        dispatch_queue_t backgroundQueue = dispatch_queue_create("me.axelrivera.queue", NULL);
        dispatch_async(backgroundQueue, ^{
            NSArray *quotesRaw = [positionsData hg_arrayOfQuoteDictionaries];
            DLog(@"%@", quotesRaw);
            
            NSMutableArray *positions = [@[] mutableCopy];
            
            for (NSDictionary *dictionary in quotesRaw) {
                HGPosition *position = [[HGPosition alloc] initWithDictionary:dictionary];
                [positions addObject:position];
            }
            
            DLog(@"positions: %@", positions);
            
            for (HGTicker *ticker in self.watchlist) {
                for (HGPosition *position in positions) {
                    if ([[ticker.symbol uppercaseString] isEqualToString:[position.symbol uppercaseString]]) {
                        ticker.position = position;
                        break;
                    }
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(self.watchlist, nil);
                }
            });
        });
    }];
}

- (void)fetchMyPositionsWithCompletion:(HGTickersCompletionBlock)completion
{
    self.fetchingMyPositions = YES;
    
    NSMutableArray *symbols = [@[] mutableCopy];
    for (HGTicker *ticker in self.myPositions) {
        [symbols addObject:ticker.symbol];
    }

    [[YahooAPIClient sharedClient] fetchPositionsForSymbols:symbols completion:^(NSString *positionsData, NSError *error) {
        self.fetchingMyPositions = NO;
        
        if (error) {
            if (completion) {
                completion(nil, error);
            }
            return;
        }
        
        dispatch_queue_t backgroundQueue = dispatch_queue_create("me.axelrivera.queue", NULL);
        dispatch_async(backgroundQueue, ^{
            NSArray *quotesRaw = [positionsData hg_arrayOfQuoteDictionaries];
            DLog(@"%@", quotesRaw);
            
            NSMutableArray *positions = [@[] mutableCopy];
            
            for (NSDictionary *dictionary in quotesRaw) {
                HGPosition *position = [[HGPosition alloc] initWithDictionary:dictionary];
                [positions addObject:position];
            }
            
            DLog(@"positions: %@", positions);
            
            for (HGTicker *ticker in self.myPositions) {
                for (HGPosition *position in positions) {
                    if ([[ticker.symbol uppercaseString] isEqualToString:[position.symbol uppercaseString]]) {
                        ticker.position = position;
                        break;
                    }
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(self.myPositions, nil);
                }
            });
        });
    }];
}

- (void)fetchPositionForSymbol:(NSString *)symbol completion:(HGPositionCompletionBlock)completion
{
    if (IsEmpty(symbol)) {
        if (completion) {
            NSError *error = [NSError errorWithDomain:@"me.axelrivera.error" code:0 userInfo:nil];
            completion(nil, error);
        }
        return;
    }
    
    [[YahooAPIClient sharedClient] fetchPositionsForSymbols:@[ symbol ] completion:^(NSString *positionsData, NSError *error) {
        self.fetchingMyPositions = NO;
        
        if (error) {
            if (completion) {
                completion(nil, error);
            }
            return;
        }
        
        dispatch_queue_t backgroundQueue = dispatch_queue_create("me.axelrivera.queue", NULL);
        dispatch_async(backgroundQueue, ^{
            NSArray *quotesRaw = [positionsData hg_arrayOfQuoteDictionaries];            
            if (IsEmpty(quotesRaw)) {
                if (completion) {
                    NSError *error = [NSError errorWithDomain:@"me.axelrivera.error" code:0 userInfo:nil];
                    completion(nil, error);
                }
                return;
            }
            
            HGPosition *position = [[HGPosition alloc] initWithDictionary:quotesRaw[0]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(position, nil);
                }
            });
        });
    }];
}

- (void)fetchHistoricalDataForSymbol:(NSString *)symbol completion:(HGHistoryCompletionBlock)completion
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
                                                     completion:^(NSString *historicalData, NSError *error)
     {
         if (error) {
             if (completion) {
                 completion(nil, error);
             }
             return;
         }
         
         dispatch_queue_t backgroundQueue = dispatch_queue_create("me.axelrivera.queue", NULL);
         dispatch_async(backgroundQueue, ^{
             NSArray *historyRaw = [historicalData hg_arrayOfHistoricalDictionaries];
             //DLog(@"%@", historyRaw);
             
             NSMutableArray *history = [@[] mutableCopy];
             
             for (NSDictionary *dictionary in historyRaw) {
                 HGHistory *data = [[HGHistory alloc] initWithDictionary:dictionary];
                 [history addObject:data];
             }
             if (completion) {
                 completion(history, error);
             }
         });
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
        [[NSNotificationCenter defaultCenter] postNotificationName:MyPositionsReloadedNotification
                                                            object:nil
                                                          userInfo:@{ @"myPositionRemoved" : removedTicker }];
    }
}

- (void)loadData
{
    MercuryData *data = [NSKeyedUnarchiver unarchiveObjectWithFile:pathInDocumentDirectory(kMercuryDataFile)];
    if (data) {
        self.watchlist = data.watchlist;
        self.myPositions = data.myPositions;
    }
}

- (void)saveData
{
    [NSKeyedArchiver archiveRootObject:self toFile:pathInDocumentDirectory(kMercuryDataFile)];
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

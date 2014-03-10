//
//  MercuryData.m
//  Mercury
//
//  Created by Axel Rivera on 2/22/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "MercuryData.h"

#import "NSString+Yahoo.h"

@interface MercuryData ()

- (void)setFetching:(BOOL)fetching tickerType:(HGTickerType)tickerType;
- (void)setArray:(NSArray *)array forTickerType:(HGTickerType)tickerType;

- (NSMutableArray *)defaultMyPositions;
- (NSMutableArray *)defaultMyWatchlist;
- (NSMutableArray *)defaultMyIndexes;

@end

@implementation MercuryData

- (instancetype)init
{
    self = [super init];
    if (self) {
        _myPositions = [self defaultMyPositions];
        _myWatchlist = [self defaultMyWatchlist];
        _myIndexes = [self defaultMyIndexes];
        _fetchingMyPositions = NO;
        _fetchingMyWatchlist = NO;
        _fetchingMyIndexes = NO;

    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        NSArray *myIndexes = [coder decodeObjectForKey:@"MercuryDataMyIndexes"];
        NSArray *myWatchlist = [coder decodeObjectForKey:@"MercuryDataMyWatchlist"];
        NSArray *myPositions = [coder decodeObjectForKey:@"MercuryDataMyPositions"];
        
        self.myIndexes = IsEmpty(myIndexes) ? [@[] mutableCopy] : [[NSMutableArray alloc] initWithArray:myIndexes];
        self.myWatchlist = IsEmpty(myWatchlist) ? [@[] mutableCopy] : [[NSMutableArray alloc] initWithArray:myWatchlist];
        self.myPositions = IsEmpty(myPositions) ? [@[] mutableCopy] : [[NSMutableArray alloc] initWithArray:myPositions];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.myIndexes forKey:@"MercuryDataMyIndexes"];
    [coder encodeObject:self.myWatchlist forKey:@"MercuryDataMyWatchlist"];
    [coder encodeObject:self.myPositions forKey:@"MercuryDataMyPositions"];
}

- (void)addTicker:(HGTicker *)ticker tickerType:(HGTickerType)tickerType
{
    NSMutableArray *array = [self arrayForTickerType:tickerType];
    [array addObject:ticker];
}

- (void)insertTicker:(HGTicker *)ticker atIndex:(NSInteger)index tickerType:(HGTickerType)tickerType
{
    NSMutableArray *array = [self arrayForTickerType:tickerType];
    [array insertObject:ticker atIndex:index];
}

- (void)removeTickerAtIndex:(NSInteger)index tickerType:(HGTickerType)tickerType
{
    NSMutableArray *array = [self arrayForTickerType:tickerType];
    [array removeObjectAtIndex:index];
}

- (void)removeAllTickersForTickerType:(HGTickerType)tickerType
{
    NSMutableArray *array = [self arrayForTickerType:tickerType];
    [array removeAllObjects];
}

- (void)fetchAllPositionsWithCompletion:(HGAllPositionsCompletionBlock)completion
{
    [self setFetching:YES tickerType:HGTickerTypeMyIndexes];
    [self setFetching:YES tickerType:HGTickerTypeMyWatchlist];
    [self setFetching:YES tickerType:HGTickerTypeMyPositions];
    
    NSMutableArray *symbols = [@[] mutableCopy];
    
    for (HGTicker *ticker in self.myIndexes) {
        [symbols addObject:ticker.symbol];
    }
    
    for (HGTicker *ticker in self.myWatchlist) {
        [symbols addObject:ticker.symbol];
    }
    
    for (HGTicker *ticker in self.myPositions) {
        [symbols addObject:ticker.symbol];
    }
    
    NSSet *symbolsSet = [NSSet setWithArray:symbols];
    
    [[YahooAPIClient sharedClient] fetchPositionsForSymbols:[symbolsSet allObjects] completion:^(NSString *positionsData, NSError *error) {
        [self setFetching:NO tickerType:HGTickerTypeMyIndexes];
        [self setFetching:NO tickerType:HGTickerTypeMyWatchlist];
        [self setFetching:NO tickerType:HGTickerTypeMyPositions];
        
        if (error) {
            if (completion) {
                completion(nil, error);
            }
            return;
        }
        
        dispatch_queue_t backgroundQueue = dispatch_queue_create(kMercuryDispatchQueue, NULL);
        dispatch_async(backgroundQueue, ^{
            NSArray *quotesRaw = [positionsData hg_arrayOfQuoteDictionaries];
            
            NSMutableArray *positions = [@[] mutableCopy];
            
            for (NSDictionary *dictionary in quotesRaw) {
                HGPosition *position = [[HGPosition alloc] initWithDictionary:dictionary];
                [positions addObject:position];
            }
            
            for (HGTicker *ticker in self.myIndexes) {
                for (HGPosition *position in positions) {
                    if ([[ticker.symbol uppercaseString] isEqualToString:[position.symbol uppercaseString]]) {
                        ticker.position = position;
                        break;
                    }
                }
            }
            
            for (HGTicker *ticker in self.myWatchlist) {
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
            
            NSDictionary *userInfo = @{ kHGMyIndexes : self.myIndexes,
                                        kHGMyWatchlist : self.myWatchlist,
                                        kHGMyPositions : self.myPositions };
            
            [[NSNotificationCenter defaultCenter] postNotificationName:AllPositionsReloadedNotification
                                                                object:nil
                                                              userInfo:userInfo];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(userInfo, nil);
                }
            });
        });
    }];
}

- (void)fetchTickerType:(HGTickerType)tickerType completion:(HGTickersCompletionBlock)completion
{
    [self setFetching:YES tickerType:tickerType];
    NSMutableArray *tickers = [self arrayForTickerType:tickerType];
    
    NSMutableArray *symbols = [@[] mutableCopy];
    for (HGTicker *ticker in tickers) {
        [symbols addObject:ticker.symbol];
    }
    
    [[YahooAPIClient sharedClient] fetchPositionsForSymbols:symbols completion:^(NSString *positionsData, NSError *error) {
        [self setFetching:NO tickerType:tickerType];
        
        if (error) {
            if (completion) {
                completion(nil, error);
            }
            return;
        }
        
        dispatch_queue_t backgroundQueue = dispatch_queue_create(kMercuryDispatchQueue, NULL);
        dispatch_async(backgroundQueue, ^{
            NSArray *quotesRaw = [positionsData hg_arrayOfQuoteDictionaries];
            
            NSMutableArray *positions = [@[] mutableCopy];
            
            for (NSDictionary *dictionary in quotesRaw) {
                HGPosition *position = [[HGPosition alloc] initWithDictionary:dictionary];
                [positions addObject:position];
            }
            
            NSMutableArray *tickers = [self arrayForTickerType:tickerType];
            
            for (HGTicker *ticker in tickers) {
                for (HGPosition *position in positions) {
                    if ([[ticker.symbol uppercaseString] isEqualToString:[position.symbol uppercaseString]]) {
                        ticker.position = position;
                        break;
                    }
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(tickers, nil);
                }
            });
        });
    }];
}

- (void)fetchPositionForSymbol:(NSString *)symbol completion:(HGPositionCompletionBlock)completion
{
    if (IsEmpty(symbol)) {
        if (completion) {
            NSError *error = [NSError errorWithDomain:kMercuryErrorDomain code:0 userInfo:nil];
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
        
        dispatch_queue_t backgroundQueue = dispatch_queue_create(kMercuryDispatchQueue, NULL);
        dispatch_async(backgroundQueue, ^{
            NSArray *quotesRaw = [positionsData hg_arrayOfQuoteDictionaries];            
            if (IsEmpty(quotesRaw)) {
                if (completion) {
                    NSError *error = [NSError errorWithDomain:kMercuryErrorDomain code:0 userInfo:nil];
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

- (void)fetchHistoricalDataForTicker:(HGTicker *)ticker completion:(HGHistoryCompletionBlock)completion
{
    NSString *period = @"d";
    NSDate *tomorrow = [NSDate tomorrowAtMidnight];
    NSDate *startDate = [tomorrow dateBySubtractingDays:HGChartHistoricalStartInterval];
    
    [[YahooAPIClient sharedClient] fetchHistoricalDataForSymbol:ticker.symbol
                                                          start:startDate
                                                            end:tomorrow
                                                         period:period
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
             
             NSMutableArray *history = [@[] mutableCopy];
             
             for (NSDictionary *dictionary in historyRaw) {
                 HGHistory *data = [[HGHistory alloc] initWithDictionary:dictionary];
                 [history addObject:data];
             }
             
             if (!IsEmpty(history) && ticker.position) {
                 HGHistory *firstObject = history[0];
                 NSDate *currentDate = [ticker.position lastTradeDate];
                 
                 if ([firstObject.date compare:currentDate] == NSOrderedDescending) {
                     HGHistory *currentHistory = [[HGHistory alloc] init];
                     currentHistory.date = currentDate;
                     [currentHistory setCloseFromString:ticker.position.close];
                     [history insertObject:currentHistory atIndex:0];
                 }
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
        self.myIndexes = data.myIndexes;
        self.myWatchlist = data.myWatchlist;
        self.myPositions = data.myPositions;
    }
}

- (void)saveData
{
    [NSKeyedArchiver archiveRootObject:self toFile:pathInDocumentDirectory(kMercuryDataFile)];
}

#pragma mark - Private Methods

- (void)setFetching:(BOOL)fetching tickerType:(HGTickerType)tickerType;
{
    switch (tickerType) {
        case HGTickerTypeMyIndexes:
            self.fetchingMyIndexes = fetching;
            break;
        case HGTickerTypeMyWatchlist:
            self.fetchingMyWatchlist = fetching;
            break;
        case HGTickerTypeMyPositions:
            self.fetchingMyPositions = fetching;
            break;
        default:
            break;
    }
}

- (NSMutableArray *)arrayForTickerType:(HGTickerType)tickerType
{
    NSMutableArray *array = [@[] mutableCopy];
    switch (tickerType) {
        case HGTickerTypeMyIndexes:
            array = self.myIndexes;
            break;
        case HGTickerTypeMyWatchlist:
            array = self.myWatchlist;
            break;
        case HGTickerTypeMyPositions:
            array = self.myPositions;
            break;
        default:
            break;
    }
    return array;
}

- (void)setArray:(NSArray *)array forTickerType:(HGTickerType)tickerType
{
    if (IsEmpty(array)) {
        array = @[];
    }
    
    switch (tickerType) {
        case HGTickerTypeMyIndexes:
            self.myIndexes = [array mutableCopy];
            break;
        case HGTickerTypeMyWatchlist:
            self.myWatchlist = [array mutableCopy];
            break;
        case HGTickerTypeMyPositions:
            self.myPositions = [array mutableCopy];
            break;
        default:
            break;
    }
}

- (NSMutableArray *)defaultMyPositions
{
    NSMutableArray *array = [@[] mutableCopy];
    
    [array addObject:[HGTicker tickerWithType:HGTickerTypeMyPositions symbol:@"JSVAX"]];
    [array addObject:[HGTicker tickerWithType:HGTickerTypeMyPositions symbol:@"SWLSX"]];
    [array addObject:[HGTicker tickerWithType:HGTickerTypeMyWatchlist symbol:@"PBW"]];
    
    return array;
}

- (NSMutableArray *)defaultMyWatchlist
{
    NSMutableArray *array = [@[] mutableCopy];

    [array addObject:[HGTicker tickerWithType:HGTickerTypeMyWatchlist symbol:@"RPG"]];
    [array addObject:[HGTicker tickerWithType:HGTickerTypeMyWatchlist symbol:@"OBEGX"]];
    [array addObject:[HGTicker tickerWithType:HGTickerTypeMyWatchlist symbol:@"SPY"]];
    [array addObject:[HGTicker tickerWithType:HGTickerTypeMyWatchlist symbol:@"SWANX"]];
    [array addObject:[HGTicker tickerWithType:HGTickerTypeMyWatchlist symbol:@"VEIEX"]];
    [array addObject:[HGTicker tickerWithType:HGTickerTypeMyWatchlist symbol:@"RYURX"]];
    
    return array;
}

- (NSMutableArray *)defaultMyIndexes
{
    NSMutableArray *array = [@[] mutableCopy];

    [array addObject:[HGTicker tickerWithType:HGTickerTypeMyIndexes symbol:@"^GSPC"]];
    [array addObject:[HGTicker tickerWithType:HGTickerTypeMyIndexes symbol:@"^W5000"]];
    [array addObject:[HGTicker tickerWithType:HGTickerTypeMyWatchlist symbol:@"^RUT"]];
    
    return array;
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

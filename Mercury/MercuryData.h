//
//  MercuryData.h
//  Mercury
//
//  Created by Axel Rivera on 2/22/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString * const HGTickerTypeMyPositionsKey;
FOUNDATION_EXPORT NSString * const HGTickerTypeMyWatchlistKey;
FOUNDATION_EXPORT NSString * const HGTickerTypeMyIndexesKey;

typedef void(^HGTickersCompletionBlock)(NSArray *tickers, NSError *error);
typedef void(^HGAllPositionsCompletionBlock)(NSDictionary *tickerDictionary, NSError *error);
typedef void(^HGHistoryCompletionBlock)(NSArray *history, NSError *error);
typedef void(^HGPositionCompletionBlock)(HGPosition *position, NSError *error);
typedef void(^HGPositionSaveCompletionBlock)(BOOL succeded, NSError *error);

@interface MercuryData : NSObject <NSCoding>

@property (strong, atomic) NSMutableArray *myIndexes;
@property (strong, atomic) NSMutableArray *myWatchlist;
@property (strong, atomic) NSMutableArray *myPositions;

@property (assign, atomic, getter = isFetchingMyIndexes) BOOL fetchingMyIndexes;
@property (assign, atomic, getter = isFetchingMyWatchlist) BOOL fetchingMyWatchlist;
@property (assign, atomic, getter = isFetchingMyPositions) BOOL fetchingMyPositions;

+ (NSString *)keyForTickerType:(HGTickerType)tickerType;
+ (HGTickerType)typeForTickerKey:(NSString *)tickerKey;
+ (NSString *)titleForTickerType:(HGTickerType)tickerType;

- (NSMutableArray *)arrayForTickerType:(HGTickerType)tickerType;
- (void)addTicker:(HGTicker *)ticker tickerType:(HGTickerType)tickerType completion:(HGPositionSaveCompletionBlock)completion;
- (void)insertTicker:(HGTicker *)ticker atIndex:(NSInteger)index tickerType:(HGTickerType)tickerType;
- (void)removeTickerAtIndex:(NSInteger)index tickerType:(HGTickerType)tickerType;
- (void)removeAllTickersForTickerType:(HGTickerType)tickerType;
- (NSInteger)indexOfTicker:(HGTicker *)ticker;

- (void)fetchAllPositionsWithCompletion:(HGAllPositionsCompletionBlock)completion;
- (void)fetchTickerType:(HGTickerType)tickerType completion:(HGTickersCompletionBlock)completion;

- (void)fetchPositionForSymbol:(NSString *)symbol completion:(HGPositionCompletionBlock)completion;

- (void)fetchHistoricalDataForTicker:(HGTicker *)ticker completion:(HGHistoryCompletionBlock)completion;

- (BOOL)isSymbolPresentInMyPositions:(NSString *)symbol;
- (void)removePositionWithSymbol:(NSString *)symbol;

- (void)loadData;
- (void)saveData;

+ (instancetype)sharedData;

@end

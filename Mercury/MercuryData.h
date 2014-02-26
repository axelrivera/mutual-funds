//
//  MercuryData.h
//  Mercury
//
//  Created by Axel Rivera on 2/22/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^HGTickersCompletionBlock)(NSArray *tickers, NSError *error);
typedef void(^HGAllPositionsCompletionBlock)(NSArray *watchlist, NSArray *myPositions, NSError *error);
typedef void(^HGHistoryCompletionBlock)(NSArray *history, NSError *error);
typedef void(^HGPositionCompletionBlock)(HGPosition *position, NSError *error);

@interface MercuryData : NSObject <NSCoding>

@property (strong, nonatomic) NSMutableArray *watchlist;
@property (strong, nonatomic) NSMutableArray *myPositions;
@property (assign, nonatomic, getter = isFetchingWatchlist) BOOL fetchingWatchlist;
@property (assign, nonatomic, getter = isFetchingMyPositions) BOOL fetchingMyPositions;

- (void)fetchAllPositionsWithCompletion:(HGAllPositionsCompletionBlock)completion;
- (void)fetchWatchlistWithCompletion:(HGTickersCompletionBlock)completion;
- (void)fetchMyPositionsWithCompletion:(HGTickersCompletionBlock)completion;
- (void)fetchPositionForSymbol:(NSString *)symbol completion:(HGPositionCompletionBlock)completion;

- (void)fetchHistoricalDataForSymbol:(NSString *)symbol completion:(HGHistoryCompletionBlock)completion;

- (BOOL)isSymbolPresentInMyPositions:(NSString *)symbol;
- (void)removePositionWithSymbol:(NSString *)symbol;

- (void)loadData;
- (void)saveData;

+ (instancetype)sharedData;

@end

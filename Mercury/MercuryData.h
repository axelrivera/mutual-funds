//
//  MercuryData.h
//  Mercury
//
//  Created by Axel Rivera on 2/22/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MercuryData : NSObject

@property (strong, nonatomic) NSMutableArray *watchlist;
@property (strong, nonatomic) NSMutableArray *myPositions;

- (void)fetchWatchlistWithCompletion:(HGPositionsCompletionBlock)completion;
- (void)fetchMyPositionsWithCompletion:(HGPositionsCompletionBlock)completion;

- (void)fetchHistoricalDataForSymbol:(NSString *)symbol completion:(HGHistoricalDataCompletionBlock)completion;

+ (instancetype)sharedData;

@end

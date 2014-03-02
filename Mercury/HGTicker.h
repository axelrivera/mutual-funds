//
//  HGTicker.h
//  Mercury
//
//  Created by Axel Rivera on 2/23/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HGPosition.h"
#import "HGHistory.h"

typedef NS_ENUM(NSInteger, HGTickerType) {
    HGTickerTypeMyIndexes = 1000,
    HGTickerTypeMyWatchlist = 2000,
    HGTickerTypeMyPositions = 3000
};

@interface HGTicker : NSObject <NSCoding>

@property (assign, nonatomic) HGTickerType tickerType;

@property (copy, nonatomic) NSString *symbol;
@property (strong, nonatomic) HGPosition *position;

+ (instancetype)tickerWithType:(HGTickerType)tickerType symbol:(NSString *)symbol;

- (NSString *)name;
- (NSString *)close;
- (NSString *)priceAndPercentChange;

@end

//
//  HGTicker.m
//  Mercury
//
//  Created by Axel Rivera on 2/23/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "HGTicker.h"

@implementation HGTicker

+ (instancetype)tickerWithType:(HGTickerType)tickerType symbol:(NSString *)symbol
{
    HGTicker *ticker = [[HGTicker alloc] init];
    ticker.tickerType = tickerType;
    ticker.symbol = symbol;
    ticker.position = nil;

    return ticker;
}

- (NSString *)name
{
    return self.position == nil ? @"" : self.position.name;
}

- (NSString *)close
{
    return self.position == nil ? @"" : self.position.close;
}

- (NSString *)priceAndPercentChange
{
    return self.position == nil ? @"" : [self.position priceAndPercentageChange];
}

@end

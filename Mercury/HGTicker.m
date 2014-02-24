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

    return ticker;
}

@end

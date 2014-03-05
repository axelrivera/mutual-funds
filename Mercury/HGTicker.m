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

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _symbol = [dictionary[@"symbol"] copy];
        _tickerName = [dictionary[@"name"] copy];
        _exchange = [dictionary[@"exch"] copy];
        _positionType = dictionary[@"typeDisp"];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        _tickerType = [coder decodeIntegerForKey:@"HGTickerTickerType"];
        _symbol = [[coder decodeObjectForKey:@"HGTickerSymbol"] copy];
        _position = [coder decodeObjectForKey:@"HGTickerPosition"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeInteger:self.tickerType forKey:@"HGTickerTickerType"];
    [coder encodeObject:self.symbol forKey:@"HGTickerSymbol"];
    [coder encodeObject:self.position forKey:@"HGTickerPosition"];
}

- (NSString *)name
{
    return self.position == nil ? @"" : self.position.name;
}

- (NSString *)close
{
    return self.position == nil ? @"" : [self.position formattedClose];
}

- (NSString *)priceAndPercentChange
{
    return self.position == nil ? @"" : [self.position priceAndPercentageChange];
}

@end

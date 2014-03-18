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

+ (instancetype)fundTickerWithType:(HGTickerType)tickerType symbol:(NSString *)symbol
{
    HGTicker *ticker = [[self class] tickerWithType:tickerType symbol:symbol];
    ticker.positionType = kHGPositionTypeFund;
    return ticker;
}

+ (instancetype)ETFTickerWithType:(HGTickerType)tickerType symbol:(NSString *)symbol
{
    HGTicker *ticker = [[self class] tickerWithType:tickerType symbol:symbol];
    ticker.positionType = kHGPositionTypeETF;
    return ticker;
}

+ (instancetype)indexTickerWithType:(HGTickerType)tickerType symbol:(NSString *)symbol
{
    HGTicker *ticker = [[self class] tickerWithType:tickerType symbol:symbol];
    ticker.positionType = kHGPositionTypeIndex;
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
        _tickerName = [[coder decodeObjectForKey:@"HGTickerTickerName"] copy];
        _exchange = [[coder decodeObjectForKey:@"HGTickerExchange"] copy];
        _positionType = [[coder decodeObjectForKey:@"HGTickerPositionType"] copy];
        _position = [coder decodeObjectForKey:@"HGTickerPosition"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeInteger:self.tickerType forKey:@"HGTickerTickerType"];
    [coder encodeObject:self.symbol forKey:@"HGTickerSymbol"];
    [coder encodeObject:self.tickerName forKey:@"HGTickerTickerName"];
    [coder encodeObject:self.exchange forKey:@"HGTickerExchange"];
    [coder encodeObject:self.positionType forKey:@"HGTickerPositionType"];
    [coder encodeObject:self.position forKey:@"HGTickerPosition"];
}

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }

    if ([object respondsToSelector:@selector(symbol)]) {
		NSString *myStr = [self symbol];
		NSString *theirStr = [object symbol];
		return myStr && theirStr ? [myStr isEqualToString:theirStr] : NO;
	}
	return NO;
}

- (NSUInteger)hash
{
    return [self symbol] ? [[self symbol] hash] : [super hash];
}

- (NSString *)name
{
    NSString *name = nil;
    if (self.position) {
        name = self.position.name;
    } else {
        if (!IsEmpty(self.tickerName)) {
            name = self.tickerName;
        } else {
            name = @"";
        }
    }
    
    return name;
}

- (NSString *)close
{
    return self.position == nil ? @"" : [self.position formattedClose];
}

- (NSString *)priceAndPercentChange
{
    return self.position == nil ? @"" : [self.position priceAndPercentageChange];
}

- (NSString *)description
{
    NSString *tickerType = [MercuryData keyForTickerType:self.tickerType];
    return [NSString stringWithFormat:@"Ticker: %@, Type: %@", self.symbol, tickerType];
}

@end

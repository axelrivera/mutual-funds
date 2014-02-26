//
//  HGPosition.m
//  Mercury
//
//  Created by Axel Rivera on 2/21/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "HGPosition.h"

@implementation HGPosition

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        DLog(@"Dictionary: %@", dictionary);
        _symbol = [dictionary[@"symbol"] copy];
        _name = [dictionary[@"name"] copy];
        _close = [dictionary[@"close"] copy];
        _change = [dictionary[@"change"] copy];
        _percentageChange = [dictionary[@"change_in_percent"] copy];
        _lastTradeDate = [dictionary[@"last_trade_date"] copy];
        _stockExchange = [dictionary[@"stock_exchange"] copy];
        _previousClose = [dictionary[@"previous_close"] copy];
        _open = [dictionary[@"open"] copy];
        _bid = [dictionary[@"bid"] copy];
        _bidSize = [dictionary[@"bid_size"] copy];
        _ask = [dictionary[@"ask"] copy];
        _askSize = [dictionary[@"ask_size"] copy];
        _daysRange = [dictionary[@"days_range"] copy];
        _yearRange = [dictionary[@"weeks_range_52"] copy];
        _volume = [dictionary[@"volume"] copy];
        _avgDailyVolume = [dictionary[@"avg_daily_volume"] copy];
        _historyArray = nil;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        _symbol = [[coder decodeObjectForKey:@"HGPositionSymbol"] copy];
        _name = [[coder decodeObjectForKey:@"HGPositionName"] copy];
        _close = [[coder decodeObjectForKey:@"HGPositionClose"] copy];
        _change = [[coder decodeObjectForKey:@"HGPositionChange"] copy];
        _percentageChange = [[coder decodeObjectForKey:@"HGPositionPercentageChange"] copy];
        _lastTradeDate = [[coder decodeObjectForKey:@"HGPositionLastTradeDate"] copy];
        _stockExchange = [[coder decodeObjectForKey:@"HGPositionStockExchange"] copy];
        _previousClose = [[coder decodeObjectForKey:@"HGPositionPreviousClose"] copy];
        _open = [[coder decodeObjectForKey:@"HGPositionOpen"] copy];
        _bid = [[coder decodeObjectForKey:@"HGPositionBid"] copy];
        _bidSize = [[coder decodeObjectForKey:@"HGPositionBidSize"] copy];
        _ask = [[coder decodeObjectForKey:@"HGPositionAsk"] copy];
        _askSize = [[coder decodeObjectForKey:@"HGPositionAskSize"] copy];
        _daysRange = [[coder decodeObjectForKey:@"HGPositionDaysRange"] copy];
        _yearRange = [[coder decodeObjectForKey:@"HGPositionYearRange"] copy];
        _volume = [[coder decodeObjectForKey:@"HGPositionVolume"] copy];
        _avgDailyVolume = [[coder decodeObjectForKey:@"HGPositionAvgDailyVolume"] copy];
        _historyArray = [[coder decodeObjectForKey:@"HGPositionHistoryArray"] copy];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.symbol forKey:@"HGPositionSymbol"];
    [coder encodeObject:self.name forKey:@"HGPositionName"];
    [coder encodeObject:self.close forKey:@"HGPositionClose"];
    [coder encodeObject:self.change forKey:@"HGPositionChange"];
    [coder encodeObject:self.percentageChange forKey:@"HGPositionPercentageChange"];
    [coder encodeObject:self.lastTradeDate forKey:@"HGPositionLastTradeDate"];
    [coder encodeObject:self.stockExchange forKey:@"HGPositionStockExchange"];
    [coder encodeObject:self.previousClose forKey:@"HGPositionPreviousClose"];
    [coder encodeObject:self.open forKey:@"HGPositionOpen"];
    [coder encodeObject:self.bid forKey:@"HGPositionBid"];
    [coder encodeObject:self.bidSize forKey:@"HGPositionBidSize"];
    [coder encodeObject:self.ask forKey:@"HGPositionAsk"];
    [coder encodeObject:self.askSize forKey:@"HGPositionAskSize"];
    [coder encodeObject:self.daysRange forKey:@"HGPositionDaysRange"];
    [coder encodeObject:self.yearRange forKey:@"HGPositionYearRange"];
    [coder encodeObject:self.volume forKey:@"HGPositionVolume"];
    [coder encodeObject:self.avgDailyVolume forKey:@"HGPositionAvgDailyVolume"];
    [coder encodeObject:self.historyArray forKey:@"HGPositionHistoryArray"];
}

- (NSString *)priceAndPercentageChange
{
    return [NSString stringWithFormat:@"%@ (%@)", self.change, self.percentageChange];
}

- (NSArray *)chartArrayForInterval:(NSUInteger)interval SMA1:(NSUInteger)SMA1 SMA2:(NSUInteger)SMA2
{
    NSArray *SMA1Array = [self SMAArrayForInterval:SMA1 + interval period:SMA1];
    NSArray *SMA2Array = [self SMAArrayForInterval:SMA2 + interval period:SMA2];
    
    NSMutableArray *resultArray = [@[] mutableCopy];
    
    NSInteger totalHistory = [self.historyArray count];
    NSInteger totalSMA1 = [SMA1Array count];
    NSInteger totalSMA2 = [SMA2Array count];
    
    for (NSInteger i = 0; i < interval; i++) {
        id close = [NSNull null];
        id SMA1Value = [NSNull null];
        id SMA2Value = [NSNull null];
        
        if (i < totalHistory) {
            HGHistory *history = self.historyArray[i];
            close = history.close;
        }
        
        if (i < totalSMA1) {
            SMA1Value = SMA1Array[i];
        }
        
        if (i < totalSMA2) {
            SMA2Value = SMA2Array[i];
        }
        
        [resultArray addObject:@{ @"close" : close, @"sma1" : SMA1Value, @"sma2" : SMA2Value }];
    }
    
    return [resultArray reversedArray];
}

- (NSArray *)SMAArrayForInterval:(NSUInteger)interval period:(NSUInteger)period
{
    NSArray *intervalArray = [self historySubarrayForInterval:interval];
    
    NSMutableArray *array = [@[] mutableCopy];
    
    for (NSInteger i = 0; i < [intervalArray count]; i++) {
        id value = [NSNull null];
        if (i + period < [intervalArray count]) {
            NSDecimalNumber *decimalPeriod = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithInteger:period] decimalValue]];
            NSMutableArray *collection = [[intervalArray subarrayWithRange:NSMakeRange(i, period)] mutableCopy];
            value = [[collection sumHistoryCloses] decimalNumberByDividingBy:decimalPeriod];
        }
        
        [array addObject:value];
    }
        
    return array;
}

- (NSArray *)historySubarrayForInterval:(NSUInteger)interval
{
    NSArray *array = @[];
    if ([self.historyArray count] < interval) {
        array = [NSArray arrayWithArray:self.historyArray];
    } else {
        array = [self.historyArray subarrayWithRange:NSMakeRange(0, interval)];
    }
    return array;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"name: %@, close: %@, change: %@", self.name, self.close, [self priceAndPercentageChange]];
}

@end

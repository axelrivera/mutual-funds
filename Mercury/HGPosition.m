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
        _ask = [dictionary[@"ask_size"] copy];
        _daysRange = [dictionary[@"days_range"] copy];
        _yearRange = [dictionary[@"weeks_range_52"] copy];
        _volume = [dictionary[@"volume"] copy];
        _avgDailyVolume = [dictionary[@"avg_daily_volume"] copy];
        _historyArray = nil;
    }
    return self;
}

- (NSString *)priceAndPercentageChange
{
    return [NSString stringWithFormat:@"%@ (%@)", self.change, self.percentageChange];
}

- (void)setHistoryArray:(NSArray *)historyArray
{
    _historyArray = historyArray;
    [self calculateSMA1];
    [self calculateSMA2];
}

- (void)calculateSMA1
{
    NSInteger period = 50;
    if (IsEmpty(_historyArray) || [_historyArray count] < period + 1) {
        return;
    }
    
    for (NSInteger i = 0; i < [_historyArray count]; i++) {
        HGHistory *current = self.historyArray[i];
        @try {
            NSDecimalNumber *decimalPeriod = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithInteger:period] decimalValue]];
            NSMutableArray *collection = [[_historyArray subarrayWithRange:NSMakeRange(i, period)] mutableCopy];
            current.sma1 = [[collection sumHistoryCloses] decimalNumberByDividingBy:decimalPeriod];
        }
        @catch (NSException *exception) {
            current.sma1 = nil;
        }
    }
}

- (void)calculateSMA2
{
    NSInteger period = 200;
    if (IsEmpty(_historyArray) || [_historyArray count] < period + 1) {
        return;
    }
    
    for (NSInteger i = 0; i < [_historyArray count]; i++) {
        HGHistory *current = _historyArray[i];
        @try {
            NSDecimalNumber *decimalPeriod = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithInteger:period] decimalValue]];
            NSMutableArray *collection = [[_historyArray subarrayWithRange:NSMakeRange(i, period)] mutableCopy];
            current.sma2 = [[collection sumHistoryCloses] decimalNumberByDividingBy:decimalPeriod];
        }
        @catch (NSException *exception) {
            current.sma2 = nil;
        }
    }
}

@end

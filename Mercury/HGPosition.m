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
        _lastTradeDateString = [dictionary[@"last_trade_date"] copy];
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
        _history = nil;
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
        _lastTradeDateString = [[coder decodeObjectForKey:@"HGPositionLastTradeDateString"] copy];
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
        _history = [[coder decodeObjectForKey:@"HGPositionHistory"] copy];
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
    [coder encodeObject:self.lastTradeDateString forKey:@"HGPositionLastTradeDateString"];
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
    [coder encodeObject:self.history forKey:@"HGPositionHistory"];
}

- (NSString *)priceAndPercentageChange
{
    return [NSString stringWithFormat:@"%@ (%@)", self.change, self.percentageChange];
}

- (NSString *)formattedClose
{
    NSNumber *number = [[NSNumberFormatter hg_closeFormatter] numberFromString:self.close];
    return [[NSNumberFormatter hg_closeFormatter] stringFromNumber:number];
}

- (NSDate *)lastTradeDate
{
    NSDate *date = [[NSDateFormatter hg_lastTradeDateFormatter] dateFromString:self.lastTradeDateString];
    return date;
}

- (HGPositionChangeType)changeType
{
    NSNumber *changeNumber = [[NSNumberFormatter hg_changeFormatter] numberFromString:self.change];
    NSComparisonResult compare = [changeNumber compare:@0.00];
    
    HGPositionChangeType result = HGPositionChangeTypeNone;
    
    if (compare == NSOrderedSame) {
        result = HGPositionChangeTypeNone;
    } else if (compare == NSOrderedAscending) {
        result = HGPositionChangeTypeNegative;
    } else if (compare == NSOrderedDescending) {
        result = HGPositionChangeTypePositive;
    }
    return  result;
}

- (UIColor *)colorForChangeType
{
    HGPositionChangeType changeType = [self changeType];
    UIColor *color = [UIColor hg_textColor];
    if (changeType == HGPositionChangeTypeNone) {
        color = [UIColor hg_changeNoneColor];
    } else if (changeType == HGPositionChangeTypePositive) {
        color = [UIColor hg_changePositiveColor];
    } else if (changeType == HGPositionChangeTypeNegative) {
        color = [UIColor hg_changeNegativeColor];
    }
    return color;
}

- (void)historyForChartRange:(NSString *)chartRange block:(HGPositionHistoryBlock)block
{
    if (!block) {
        return;
    }

    dispatch_queue_t backgroundQueue = dispatch_queue_create(kMercuryDispatchQueue, NULL);
    dispatch_async(backgroundQueue, ^{
        NSArray *tmpHistory = @[];
        
        NSDate *tomorrow = [NSDate tomorrowAtMidnight];
        NSDate *epochDate = [tomorrow dateBySubtractingDays:HGChartHistoricalStartInterval];
        
        if ([chartRange isEqualToString:HGChartRangeTenYearWeekly]) {
            tmpHistory = [self.history hg_weeklyArrayWithStartDate:epochDate];
        } else {
            tmpHistory = [self.history hg_dailyArrayWithStartDate:epochDate];
        }
        
        NSUInteger interval = [[HGSettings defaultSettings] intervalForChartRange:chartRange];
        NSDate *endDate = [NSDate chartEndDate];
        NSDate *startDate = [NSDate chartStartDateForEndDate:endDate interval:interval];

        NSUInteger SMA1Period = [[HGSettings defaultSettings] SMA1PeriodForChartRange:chartRange];
        NSArray *SMA1Array = [tmpHistory SMA_arrayForPeriod:SMA1Period interval:interval];

        NSUInteger SMA2Period = [[HGSettings defaultSettings] SMA2PeriodForChartRange:chartRange];
        NSArray *SMA2Array = [tmpHistory SMA_arrayForPeriod:SMA2Period interval:interval];

        NSArray *history = [tmpHistory hg_subarrayWithStartDate:startDate];
        NSArray *SMA1 = [SMA1Array hg_subarrayWithStartDate:startDate];
        NSArray *SMA2 = [SMA2Array hg_subarrayWithStartDate:startDate];

        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                block(history, SMA1, SMA2);
            }
        });

    });
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"name: %@, close: %@, change: %@", self.name, self.close, [self priceAndPercentageChange]];
}

@end

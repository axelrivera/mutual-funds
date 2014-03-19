//
//  HGPosition.h
//  Mercury
//
//  Created by Axel Rivera on 2/21/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, HGPositionChangeType) {
    HGPositionChangeTypeNone,
    HGPositionChangeTypePositive,
    HGPositionChangeTypeNegative
};

typedef void(^HGPositionHistoryBlock)(NSArray *history, NSArray *SMA1, NSArray *SMA2);

@interface HGPosition : NSObject <NSCoding>

@property (copy, nonatomic) NSString *symbol;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *close;
@property (copy, nonatomic) NSString *change;
@property (copy, nonatomic) NSString *percentageChange;
@property (copy, nonatomic) NSString *lastTradeDateString;
@property (copy, nonatomic) NSString *lastTradeTime;
@property (copy, nonatomic) NSString *stockExchange;
@property (copy, nonatomic) NSString *previousClose;
@property (copy, nonatomic) NSString *open;
@property (copy, nonatomic) NSString *bid;
@property (copy, nonatomic) NSString *bidSize;
@property (copy, nonatomic) NSString *ask;
@property (copy, nonatomic) NSString *askSize;
@property (copy, nonatomic) NSString *low;
@property (copy, nonatomic) NSString *high;
@property (copy, nonatomic) NSString *yearLow;
@property (copy, nonatomic) NSString *yearHigh;
@property (copy, nonatomic) NSString *volume;
@property (copy, nonatomic) NSString *avgDailyVolume;

@property (strong, nonatomic) NSArray *history;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (NSString *)priceAndPercentageChange;
- (NSString *)formattedOpen;
- (NSString *)formattedClose;
- (NSString *)formattedPreviousClose;
- (NSString *)formattedDayRange;
- (NSString *)formattedYearRange;
- (NSString *)formattedVolume;
- (NSString *)formattedAvgDailyVolume;
- (NSDate *)lastTradeDate;
- (HGPositionChangeType)changeType;
- (UIColor *)colorForChangeType;

- (void)historyForChartRange:(NSString *)chartRange block:(HGPositionHistoryBlock)block;

@end

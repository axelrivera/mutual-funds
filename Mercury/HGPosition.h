//
//  HGPosition.h
//  Mercury
//
//  Created by Axel Rivera on 2/21/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HGPosition : NSObject <NSCoding>

@property (copy, nonatomic) NSString *symbol;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *close;
@property (copy, nonatomic) NSString *change;
@property (copy, nonatomic) NSString *percentageChange;
@property (copy, nonatomic) NSString *lastTradeDate;
@property (copy, nonatomic) NSString *lastTradeTime;
@property (copy, nonatomic) NSString *stockExchange;
@property (copy, nonatomic) NSString *previousClose;
@property (copy, nonatomic) NSString *open;
@property (copy, nonatomic) NSString *bid;
@property (copy, nonatomic) NSString *bidSize;
@property (copy, nonatomic) NSString *ask;
@property (copy, nonatomic) NSString *askSize;
@property (copy, nonatomic) NSString *daysRange;
@property (copy, nonatomic) NSString *yearRange;
@property (copy, nonatomic) NSString *volume;
@property (copy, nonatomic) NSString *avgDailyVolume;

@property (strong, nonatomic) NSArray *history;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (NSString *)priceAndPercentageChange;

- (NSArray *)chartArrayForInterval:(NSUInteger)interval SMA1:(NSUInteger)SMA1 SMA2:(NSUInteger)SMA2;

@end
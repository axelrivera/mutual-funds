//
//  HGHistory.m
//  Mercury
//
//  Created by Axel Rivera on 2/22/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "HGHistory.h"

@implementation HGHistory

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _date = [[[NSDateFormatter hg_shortDateFormatter] dateFromString:dictionary[@"date"]] copy];
        _close = [[NSDecimalNumber decimalNumberWithString:dictionary[@"close"]] copy];
        _open = [[NSDecimalNumber decimalNumberWithString:dictionary[@"open"]] copy];
        _high = [[NSDecimalNumber decimalNumberWithString:dictionary[@"high"]] copy];
        _low = [[NSDecimalNumber decimalNumberWithString:dictionary[@"low"]] copy];
        _volume = [[NSNumber numberWithInteger:[dictionary[@"volume"] integerValue]] copy];
        _adjustedClose = [[NSDecimalNumber decimalNumberWithString:dictionary[@"adj_close"]] copy];
        _sma1 = [NSDecimalNumber notANumber];
        _sma2 = [NSDecimalNumber notANumber];
    }
    return self;
}

- (id)sma1Value
{
    return [self.sma1 isEqualToNumber:[NSDecimalNumber notANumber]] ? [NSNull null] : self.sma1;
}

- (id)sma2Value
{
    return [self.sma2 isEqualToNumber:[NSDecimalNumber notANumber]] ? [NSNull null] : self.sma2;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"date: %@, close: %@, sma1: %@, sma2: %@", self.date, self.close, self.sma1, self.sma2];
}

@end

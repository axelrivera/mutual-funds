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
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        _date = [[coder decodeObjectForKey:@"HGHistoryDate"] copy];
        _close = [[coder decodeObjectForKey:@"HGHistoryClose"] copy];
        _open = [[coder decodeObjectForKey:@"HGHistoryOpen"] copy];
        _high = [[coder decodeObjectForKey:@"HGHistoryHigh"] copy];
        _low = [[coder decodeObjectForKey:@"HGHistoryLow"] copy];
        _volume = [[coder decodeObjectForKey:@"HGHistoryVolume"] copy];
        _adjustedClose = [[coder decodeObjectForKey:@"HGHistoryAdjustedClose"] copy];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.date forKey:@"HGHistoryDate"];
    [coder encodeObject:self.close forKey:@"HGHistoryClose"];
    [coder encodeObject:self.open forKey:@"HGHistoryOpen"];
    [coder encodeObject:self.high forKey:@"HGHistoryHigh"];
    [coder encodeObject:self.low forKey:@"HGHistoryLow"];
    [coder encodeObject:self.volume forKey:@"HGHistoryVolume"];
    [coder encodeObject:self.adjustedClose forKey:@"HGHistoryAdjustedClose"];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"date: %@, close: %@", self.date, self.close];
}

@end

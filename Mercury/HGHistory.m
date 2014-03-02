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
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        _date = [[coder decodeObjectForKey:@"HGHistoryDate"] copy];
        _close = [[coder decodeObjectForKey:@"HGHistoryClose"] copy];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.date forKey:@"HGHistoryDate"];
    [coder encodeObject:self.close forKey:@"HGHistoryClose"];
}

- (void)setCloseFromString:(NSString *)closeString
{
    _close = [[NSDecimalNumber decimalNumberWithString:closeString] copy];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"date: %@, close: %@", self.date, self.close];
}

@end

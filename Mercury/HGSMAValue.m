//
//  HGSMAValue.m
//  Mercury
//
//  Created by Axel Rivera on 3/8/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "HGSMAValue.h"

@implementation HGSMAValue

+ (instancetype)instanceWithDate:(NSDate *)date SMA:(NSDecimalNumber *)SMA
{
    HGSMAValue *value = [[HGSMAValue alloc] init];
    value.date = date;
    value.SMA = SMA;
    return value;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"date: %@, sma: %@", self.date, self.SMA];
}

@end

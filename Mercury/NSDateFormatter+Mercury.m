//
//  NSDateFormatter+Mercury.m
//  Mercury
//
//  Created by Axel Rivera on 2/22/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "NSDateFormatter+Mercury.h"

static NSDateFormatter *_monthFormatter;
static NSDateFormatter *_dayFormatter;
static NSDateFormatter *_yearFormatter;
static NSDateFormatter *_shortDateFormatter;

@implementation NSDateFormatter (Mercury)

+ (NSDateFormatter *)hg_monthFormatter
{
    if (_monthFormatter == nil) {
        _monthFormatter = [[NSDateFormatter alloc] init];
        _monthFormatter.dateFormat = @"M";
    }
    return _monthFormatter;
}

+ (NSDateFormatter *)hg_dayFormatter
{
    if (_dayFormatter == nil) {
        _dayFormatter = [[NSDateFormatter alloc] init];
        _dayFormatter.dateFormat = @"d";
    }
    return _dayFormatter;
}

+ (NSDateFormatter *)hg_yearFormatter
{
    if (_yearFormatter == nil) {
        _yearFormatter = [[NSDateFormatter alloc] init];
        _yearFormatter.dateFormat = @"Y";
    }
    return _yearFormatter;
}

+ (NSDateFormatter *)hg_shortDateFormatter
{
    if (_shortDateFormatter == nil) {
        _shortDateFormatter = [[NSDateFormatter alloc] init];
        _shortDateFormatter.dateFormat = @"YYYY-MM-dd";
    }
    return _shortDateFormatter;
}

@end

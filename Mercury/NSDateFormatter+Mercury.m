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
static NSDateFormatter *_lastTradeDateFormatter;
static NSDateFormatter *_signalDateFormater;

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
        _yearFormatter.dateFormat = @"yyyy";
    }
    return _yearFormatter;
}

+ (NSDateFormatter *)hg_shortDateFormatter
{
    if (_shortDateFormatter == nil) {
        _shortDateFormatter = [[NSDateFormatter alloc] init];
        _shortDateFormatter.dateFormat = @"yyyy-MM-dd";
    }
    return _shortDateFormatter;
}

// Date: "2/27/2014"
// Time: "6:05pm"

+ (NSDateFormatter *)hg_lastTradeDateFormatter
{
    if (_lastTradeDateFormatter == nil) {
        _lastTradeDateFormatter = [[NSDateFormatter alloc] init];
        _lastTradeDateFormatter.dateFormat = @"MM/dd/yyyy";
    }
    return _lastTradeDateFormatter;
}

+ (NSDateFormatter *)hg_signalDateFormatter
{
    if (_signalDateFormater == nil) {
        _signalDateFormater = [[NSDateFormatter alloc] init];
        _signalDateFormater.dateStyle = NSDateFormatterFullStyle;
        _signalDateFormater.timeStyle = NSDateFormatterNoStyle;
    }
    return _signalDateFormater;
}

@end

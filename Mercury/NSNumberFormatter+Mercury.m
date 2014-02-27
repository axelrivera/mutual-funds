//
//  NSNumberFormatter+Mercury.m
//  Mercury
//
//  Created by Axel Rivera on 2/26/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "NSNumberFormatter+Mercury.h"

NSNumberFormatter *_changeFormatter;
NSNumberFormatter *_closeFormatter;

@implementation NSNumberFormatter (Mercury)

+ (NSNumberFormatter *)hg_changeFormatter
{
    if (_changeFormatter == nil) {
        _changeFormatter = [[NSNumberFormatter alloc] init];
        [_changeFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [_changeFormatter setPositivePrefix:@"+"];
        [_changeFormatter setMaximumFractionDigits:2];
    }
    return _changeFormatter;
}

+ (NSNumberFormatter *)hg_closeFormatter
{
    if (_closeFormatter == nil) {
        _closeFormatter = [[NSNumberFormatter alloc] init];
        [_closeFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [_closeFormatter setMaximumFractionDigits:2];
    }
    return _closeFormatter;
}

@end

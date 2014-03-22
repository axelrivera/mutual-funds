//
//  NSNumberFormatter+Mercury.m
//  Mercury
//
//  Created by Axel Rivera on 2/26/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "NSNumberFormatter+Mercury.h"

NSNumberFormatter *_changeFormatter;
NSNumberFormatter *_numberFormatter;
NSNumberFormatter *_integerFormatter;
NSNumberFormatter *_storePriceFormatter;

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

+ (NSNumberFormatter *)hg_numberFormatter
{
    if (_numberFormatter == nil) {
        _numberFormatter = [[NSNumberFormatter alloc] init];
        [_numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [_numberFormatter setMaximumFractionDigits:2];
    }
    return _numberFormatter;
}

+ (NSNumberFormatter *)hg_integerFormatter
{
    if (_integerFormatter == nil) {
        _integerFormatter = [[NSNumberFormatter alloc] init];
        [_integerFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [_integerFormatter setMaximumFractionDigits:0];
    }
    return _integerFormatter;
}

+ (NSNumberFormatter *)hg_storePriceFormatterWithLocale:(NSLocale *)locale
{
    if (_storePriceFormatter == nil) {
        _storePriceFormatter = [[NSNumberFormatter alloc] init];
        [_storePriceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [_storePriceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [_storePriceFormatter setLocale:locale];
    }
    
    return _storePriceFormatter;
}

@end

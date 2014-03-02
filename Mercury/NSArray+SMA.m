//
//  NSArray+SMA.m
//  Mercury
//
//  Created by Axel Rivera on 2/27/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "NSArray+SMA.h"

@implementation NSArray (SMA)

- (NSArray *)SMA_arrayOfAnalizedSignals
{
    NSMutableArray *array = [@[] mutableCopy];
    
    NSInteger total = [self count];
    
    for (NSInteger i = 1; i < total; i++) {
        NSDictionary *current = self[i];
        NSDictionary *previous = self[i - 1];
        
        NSString *signal = nil;
        
        NSDate *currentDate = current[@"date"];
        NSDecimalNumber *currentSMA1 = current[@"sma1"];
        NSDecimalNumber *currentSMA2 = current[@"sma2"];
        
        NSDecimalNumber *previousSMA1 = previous[@"sma1"];
        NSDecimalNumber *previousSMA2 = previous[@"sma2"];
        
        NSMutableDictionary *dictionary = [@{ @"date" : currentDate } mutableCopy];
        
        if ([currentSMA1 isKindOfClass:[NSNumber class]] &&
            [currentSMA2 isKindOfClass:[NSNumber class]] &&
            [previousSMA1 isKindOfClass:[NSNumber class]] &&
            [previousSMA2 isKindOfClass:[NSNumber class]])
        {
            if ([currentSMA1 isGreaterThanDecimalNumber:currentSMA2]) {
                if ([previousSMA2 isGreaterThanOrEqualToDecimalNumber:previousSMA1]) {
                    // buy signal
                    signal = @"buy";
                }
            } else if ([currentSMA1 isLessThanDecimalNumber:currentSMA2]) {
                if ([previousSMA2 isLessThanOrEqualToDecimalNumber:previousSMA1]) {
                    // sell signal
                    signal = @"sell";
                }
            }
        }
        
        if (signal) {
            dictionary[@"signal"] = signal;
            dictionary[@"close"] = current[@"close"];
            [array addObject:dictionary];
        }
    }
    return array;
}

@end

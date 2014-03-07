//
//  NSArray+SMA.m
//  Mercury
//
//  Created by Axel Rivera on 2/27/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "NSArray+SMA.h"

@implementation NSArray (SMA)

- (NSDictionary *)SMA_currentSignal
{
    if (IsEmpty(self) || [self count] < 2) {
        return nil;
    }
    
    NSDictionary *current = self[[self count] - 1];
    NSDictionary *previous = self[[self count] - 2];
    
    NSString *signal = @"not_available";
    
    NSDate *currentDate = current[@"date"];
    NSDecimalNumber *currentSMA1 = current[@"sma1"];
    NSDecimalNumber *currentSMA2 = current[@"sma2"];
    
    NSDecimalNumber *previousSMA1 = previous[@"sma1"];
    NSDecimalNumber *previousSMA2 = previous[@"sma2"];
    
    if ([currentSMA1 isKindOfClass:[NSNumber class]] &&
        [currentSMA2 isKindOfClass:[NSNumber class]] &&
        [previousSMA1 isKindOfClass:[NSNumber class]] &&
        [previousSMA2 isKindOfClass:[NSNumber class]])
    {
        if ([currentSMA1 isGreaterThanDecimalNumber:currentSMA2]) {
            if ([previousSMA2 isGreaterThanOrEqualToDecimalNumber:previousSMA1]) {
                // buy signal
                signal = @"buy";
            } else {
                signal = @"hold";
            }
        } else if ([currentSMA1 isLessThanDecimalNumber:currentSMA2]) {
            if ([previousSMA2 isLessThanOrEqualToDecimalNumber:previousSMA1]) {
                // sell signal
                signal = @"sell";
            } else {
                signal = @"avoid";
            }
        } else {
            if ([previousSMA1 isGreaterThanDecimalNumber:previousSMA2]) {
                signal = @"avoid";
            } else {
                signal = @"hold";
            }
        }
        
        if ([signal isEqualToString:@"buy"] || [signal isEqualToString:@"hold"]) {
            NSDate *startDate = [NSDate chartStartDateForInterval:HGChartPeriodThreeMonthInterval];
            NSArray *signals = [[self SMA_arrayOfAnalizedSignals] chartSubarrayWithStartDate:startDate];
            if ([signals count] > 0) {
                signal = [signal isEqualToString:@"buy"] ? @"buy_sideways" : @"hold_sideways";
            }
        }
    }
    
    return @{ @"date" : currentDate, @"signal" : signal };
}

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
    return [array reversedArray];
}

@end

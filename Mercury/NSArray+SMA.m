//
//  NSArray+SMA.m
//  Mercury
//
//  Created by Axel Rivera on 2/27/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "NSArray+SMA.h"

#import "NSArray+HGPosition.h"
#import "NSArray+Mercury.h"

@implementation NSArray (SMA)

- (NSArray *)SMA_arrayForPeriod:(NSUInteger)period interval:(NSUInteger)interval
{
    NSUInteger offset = period + interval;
    NSArray *intervalArray = [self hg_subarrayForInterval:offset];

    NSMutableArray *array = [@[] mutableCopy];

    for (NSInteger i = 0; i < [intervalArray count]; i++) {
        HGHistory *history = self[i];
        if (i + period < [intervalArray count]) {
            NSDecimalNumber *decimalPeriod = [NSDecimalNumber decimalNumberWithDecimal:
                                              [[NSNumber numberWithInteger:period] decimalValue]];

            NSMutableArray *collection = [[intervalArray subarrayWithRange:NSMakeRange(i, period)] mutableCopy];
            NSDecimalNumber *value = [[collection positionSumOfCloses] decimalNumberByDividingBy:decimalPeriod];
            
            NSString *strValue = [NSString stringWithFormat:@"%.02f", [value floatValue]];
            
            [array addObject:[HGSMAValue instanceWithDate:history.date
                                                      SMA:[NSDecimalNumber decimalNumberWithString:strValue]]];
        }
    }
    
    return array;
}

+ (void)SMA_currentSignalForHistory:(NSArray *)history SMA1:(NSArray *)SMA1 SMA2:(NSArray *)SMA2 block:(HGCurrentSignalBlock)block
{
    [self SMA_signalsForHistory:history SMA1:SMA1 SMA2:SMA2
                          block:^(BOOL succeded, NSArray *history, NSArray *SMA1, NSArray *SMA2, NSArray *signals)
    {
        if (!succeded) {
            block(NO, nil, nil);
            return;
        }

        NSString *signal = @"not_available";

        NSDecimalNumber *currentSMA1 = [SMA1[0] SMA];
        NSDecimalNumber *currentSMA2 = [SMA2[0] SMA];

        NSDecimalNumber *previousSMA1 = [SMA1[1] SMA];
        NSDecimalNumber *previousSMA2 = [SMA2[1] SMA];
        
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
            NSDate *startDate = [NSDate chartStartDateForInterval:HGChartThreeMonthInterval];
            NSArray *recentSignals = [signals hg_subarrayWithStartDate:startDate];
            DLog(@"Recent Signals: %@", recentSignals);
            for (NSDictionary *dictionary in recentSignals) {
                if ([dictionary[@"signal"] isEqualToString:@"sell"]) {
                    signal = [signal isEqualToString:@"buy"] ? @"buy_sideways" : @"hold_sideways";
                }
            }
        }
        
        DLog(@"Signals: %@", signals);
        
        if (block) {
            block(YES, signal, signals);
        }
    }];
}

+ (void)SMA_signalsForHistory:(NSArray *)history SMA1:(NSArray *)SMA1 SMA2:(NSArray *)SMA2 block:(HGSignalsBlock)block
{
    NSInteger total = MIN([SMA1 count], [SMA2 count]);

    if (total == 0) {
        block(NO, nil, nil, nil, nil);
        return;
    }
    
    NSArray *tmpHistory = [history subarrayWithRange:NSMakeRange(0, total)];
    NSArray *tmpSMA1 = [SMA1 subarrayWithRange:NSMakeRange(0, total)];
    NSArray *tmpSMA2 = [SMA2 subarrayWithRange:NSMakeRange(0, total)];
    
    if ([tmpHistory count] < 2) {
        block(NO, nil, nil, nil, nil);
        return;
    }

    NSMutableArray *signals = [@[] mutableCopy];

    for (NSInteger i = 0; i < total - 1; i++) {
        NSString *signal = nil;

        HGHistory *history = tmpHistory[i];

        NSDecimalNumber *close = history.close;
        NSDate *currentDate = history.date;

        NSDecimalNumber *currentSMA1 = [tmpSMA1[i] SMA];
        NSDecimalNumber *currentSMA2 = [tmpSMA2[i] SMA];
        
        NSDecimalNumber *previousSMA1 = [tmpSMA1[i + 1] SMA];
        NSDecimalNumber *previousSMA2 = [tmpSMA2[i + 1] SMA];
        
        NSMutableDictionary *dictionary = [@{ @"date" : currentDate } mutableCopy];

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
        
        if (signal) {
            dictionary[@"signal"] = signal;
            dictionary[@"close"] = close;
            dictionary[@"sma1"] = currentSMA1;
            dictionary[@"sma2"] = currentSMA2;
            [signals addObject:dictionary];
        }
    }
    
    if (block) {
        block(YES, tmpHistory, tmpSMA1, tmpSMA2, signals);
    }
}

@end

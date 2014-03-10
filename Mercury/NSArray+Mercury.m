//
//  NSArray+Mercury.m
//  Mercury
//
//  Created by Axel Rivera on 2/22/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "NSArray+Mercury.h"

@implementation NSArray (Mercury)

- (NSArray *)hg_reversedArray
{
    NSMutableArray *array = [@[] mutableCopy];;
    NSEnumerator *enumerator = [self reverseObjectEnumerator];
    for (id element in enumerator) {
        [array addObject:element];
    }
    return array;
}

- (NSArray *)hg_weeklyArrayWithStartDate:(NSDate *)startDate
{
    NSMutableArray *weeklyArray = [@[] mutableCopy];
    for (id object in self) {
        if ([object respondsToSelector:@selector(date)]) {
            if ([[object date] isMonday]) {
                [weeklyArray addObject:object];
            }
        }
    }
    return [weeklyArray hg_subarrayWithStartDate:startDate];
}

- (NSArray *)hg_dailyArrayWithStartDate:(NSDate *)startDate
{
    NSArray *dailyArray = [NSArray arrayWithArray:self];
    return [dailyArray hg_subarrayWithStartDate:startDate];
}

- (NSArray *)hg_subarrayWithStartDate:(NSDate *)startDate
{
    NSMutableArray *subarray = [@[] mutableCopy];
    for (id object in self) {
        if ([object isKindOfClass:[NSDictionary class]]) {
            NSDate *date = object[@"date"];
            if (date) {
                if ([startDate compare:date] == NSOrderedAscending) {
                    [subarray addObject:object];
                }
            }
        } else if ([object respondsToSelector:@selector(date)]) {
            if ([startDate compare:[object date]] == NSOrderedAscending) {
                [subarray addObject:object];
            }
        }
    }
    return subarray;
}

- (NSArray *)hg_subarrayForInterval:(NSUInteger)interval
{
    NSArray *array = @[];
    if ([self count] < interval) {
        array = [NSArray arrayWithArray:self];
    } else {
        array = [self subarrayWithRange:NSMakeRange(0, interval)];
    }
    return array;
}

+ (NSArray *)hg_sortedArrayForYStepsIncluding:(NSArray *)history SMA1:(NSArray *)SMA1 SMA2:(NSArray *)SMA2
{
    NSMutableArray *numbers = [@[] mutableCopy];
    
    for (HGHistory *current in history) {
        [numbers addObject:current.close];
    }
    
    for (HGSMAValue *current in SMA1) {
        [numbers addObject:current.SMA];
    }
    
    for (HGSMAValue *current in SMA2) {
        [numbers addObject:current.SMA];
    }
    
    NSArray *sortedNumbers = [numbers sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([obj1 isGreaterThanDecimalNumber:obj2]) {
            return NSOrderedDescending;
        } else if ([obj1 isLessThanDecimalNumber:obj2]) {
            return NSOrderedAscending;
        } else {
            return NSOrderedSame;
        }
    }];
    
    return sortedNumbers;
}

+ (NSArray *)hg_yStepsForDetailChartIncluding:(NSArray *)history SMA1:(NSArray *)SMA1 SMA2:(NSArray *)SMA2
{
    NSOrderedSet *numberSet = [NSOrderedSet orderedSetWithArray:[NSArray hg_sortedArrayForYStepsIncluding:history
                                                                                                     SMA1:SMA1
                                                                                                     SMA2:SMA2]];
    NSInteger total = [numberSet count];
    
    CGFloat third = [[numberSet objectAtIndex:total - 1] floatValue];
    CGFloat second = [[numberSet objectAtIndex:(NSInteger)round(total / 2)] floatValue];
    CGFloat first = [[numberSet objectAtIndex:0] floatValue];
    
    return @[[NSString stringWithFormat:@"%.02f", first],
             [NSString stringWithFormat:@"%.02f", second],
             [NSString stringWithFormat:@"%.02f", third] ];
}

+ (NSArray *)hg_xStepsForHistory:(NSArray *)history
{
    NSMutableArray *dates = [@[] mutableCopy];
    NSMutableArray *months = [@[] mutableCopy];
    
    NSArray *reversedHistory = [history hg_reversedArray];
    
    for (HGHistory *item in reversedHistory) {
        NSDate *date = item.date;
        NSString *month = [[NSDateFormatter hg_monthFormatter] stringFromDate:date];
        
        if (![months containsObject:month]) {
            [months addObject:month];
            [dates addObject:date];
        }
    }
    
    if ([dates count] > 2) {
        [dates removeObjectAtIndex:0];
        [dates removeLastObject];
    }
    
    NSMutableArray *cleanDates = [@[] mutableCopy];
    
    for (NSDate *date in dates) {
        [cleanDates addObject:[date dateWithFirstDayOfTheMonth]];
    }
    
    return cleanDates;
}

+ (NSDictionary *)hg_minimumAndMaximumRangeForHistory:(NSArray *)history SMA1:(NSArray *)SMA1 SMA2:(NSArray *)SMA2
{
    NSArray *sortedNumbers = [NSArray hg_sortedArrayForYStepsIncluding:history SMA1:SMA1 SMA2:SMA2];
    
    NSDecimalNumber *min = [NSDecimalNumber zero];
    NSDecimalNumber *max = [NSDecimalNumber zero];
    if ([sortedNumbers count] == 1) {
        min = sortedNumbers.firstObject;
        max = min;
    } else if ([sortedNumbers count] > 1) {
        min = sortedNumbers.firstObject;
        max = sortedNumbers.lastObject;
    }

//    NSDecimalNumber *multiplier = [NSDecimalNumber decimalNumberWithString:@"0.5"];
//    NSDecimalNumber *offset = [[max decimalNumberBySubtracting:min] decimalNumberByMultiplyingBy:multiplier];

    return @{ @"min" : min,
              @"max" : max };

}

@end

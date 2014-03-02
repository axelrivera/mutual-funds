//
//  NSArray+Mercury.m
//  Mercury
//
//  Created by Axel Rivera on 2/22/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "NSArray+Mercury.h"

@implementation NSArray (Mercury)

- (NSArray *)reversedArray
{
    NSMutableArray *array = [@[] mutableCopy];;
    NSEnumerator *enumerator = [self reverseObjectEnumerator];
    for (id element in enumerator) {
        [array addObject:element];
    }
    return array;
}

- (NSDecimalNumber *)sumHistoryCloses
{
    NSDecimalNumber *sum = [NSDecimalNumber zero];
    for (id object in self) {
        if ([object isKindOfClass:[HGHistory class]]) {
            HGHistory *history = object;
            sum = [sum decimalNumberByAdding:history.close];
        }
    }
    return sum;
}

- (NSArray *)chartWeeklyArrayWithStartDate:(NSDate *)startDate
{
    NSMutableArray *weeklyArray = [@[] mutableCopy];
    for (NSDictionary *dictionary in self) {
        NSDate *date = dictionary[@"date"];
        if ([date isMonday]) {
            [weeklyArray addObject:dictionary];
        }
    }
    return [weeklyArray chartSubarrayWithStartDate:startDate];
}

- (NSArray *)chartDailyArrayWithStartDate:(NSDate *)startDate
{
    NSArray *dailyArray = [NSArray arrayWithArray:self];
    return [dailyArray chartSubarrayWithStartDate:startDate];
}

- (NSArray *)chartSubarrayWithStartDate:(NSDate *)startDate
{
    NSMutableArray *subarray = [@[] mutableCopy];
    for (NSDictionary *dictionary in self) {
        NSDate *date = dictionary[@"date"];
        if ([startDate compare:date] == NSOrderedAscending) {
            [subarray addObject:dictionary];
        }
    }
    return subarray;
}

@end

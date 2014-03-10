//
//  NSDate+Mercury.m
//  Mercury
//
//  Created by Axel Rivera on 2/27/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "NSDate+Mercury.h"

@implementation NSDate (Mercury)

+ (NSDate *)tomorrowAtMidnight
{
    return [[[NSDate date] dateByAddingDays:1] atMidnight];
}

+ (NSDate *)chartEndDate;
{
    return [NSDate tomorrowAtMidnight];
}

+ (NSDate *)chartStartDateForInterval:(NSUInteger)interval
{
    return [self chartStartDateForEndDate:[self chartEndDate] interval:interval];
}

+ (NSDate *)chartStartDateForEndDate:(NSDate *)endDate interval:(NSUInteger)interval
{
    return [endDate dateBySubtractingDays:interval];
}

- (NSDate *)atMidnight
{
    NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:self];
    
    NSDate *date = [gregorian dateFromComponents:components];
    
    return date;
}

- (NSDate *)dateByAddingDays:(NSUInteger)days
{
	NSDateComponents *components = [[NSDateComponents alloc] init];
	components.day = days;
	return [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:self options:0];
}

- (NSDate *)dateBySubtractingDays:(NSUInteger)days
{
    return [self dateByAddingDays:-(days)];
}

- (BOOL)isMonday
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger weekday = [[calendar components:NSWeekdayCalendarUnit fromDate:self] weekday];
    return weekday == 2 ? YES : NO; // Sun = 1, Sat = 7
}

- (BOOL)isJanuary
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger month = [[calendar components:NSMonthCalendarUnit fromDate:self] month];
    return month == 1 ? YES : NO; // Jan = 1
}

- (NSDate *)dateWithFirstDayOfTheMonth
{
    NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:self];
    
    [components setDay:1];
    
    return [gregorian dateFromComponents:components];
}

@end

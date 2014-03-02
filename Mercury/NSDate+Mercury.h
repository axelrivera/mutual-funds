//
//  NSDate+Mercury.h
//  Mercury
//
//  Created by Axel Rivera on 2/27/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Mercury)

+ (NSDate *)tomorrowAtMidnight;
+ (NSDate *)chartEndDate;
+ (NSDate *)chartStartDateForInterval:(NSUInteger)interval;
+ (NSDate *)chartStartDateForEndDate:(NSDate *)endDate interval:(NSUInteger)interval;

- (NSDate *)atMidnight;
- (NSDate *)dateByAddingDays:(NSUInteger)days;
- (NSDate *)dateBySubtractingDays:(NSUInteger)days;

- (BOOL)isMonday;

@end

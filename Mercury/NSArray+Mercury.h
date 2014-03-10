//
//  NSArray+Mercury.h
//  Mercury
//
//  Created by Axel Rivera on 2/22/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Mercury)

- (NSArray *)hg_reversedArray;

- (NSArray *)hg_weeklyArrayWithStartDate:(NSDate *)startDate;
- (NSArray *)hg_dailyArrayWithStartDate:(NSDate *)startDate;
- (NSArray *)hg_subarrayWithStartDate:(NSDate *)startDate;
- (NSArray *)hg_subarrayForInterval:(NSUInteger)interval;

+ (NSArray *)hg_sortedArrayForYStepsIncluding:(NSArray *)history SMA1:(NSArray *)SMA1 SMA2:(NSArray *)SMA2;
+ (NSArray *)hg_yStepsForDetailChartIncluding:(NSArray *)history SMA1:(NSArray *)SMA1 SMA2:(NSArray *)SMA2;
+ (NSArray *)hg_yStepsForFullscreenChartIncluding:(NSArray *)history SMA1:(NSArray *)SMA1 SMA2:(NSArray *)SMA2;

+ (NSArray *)hg_xStepsInMonthsForHistory:(NSArray *)history;
+ (NSArray *)hg_xStepsInYearsForHistory:(NSArray *)history;

+ (NSDictionary *)hg_minimumAndMaximumRangeForHistory:(NSArray *)history SMA1:(NSArray *)SMA1 SMA2:(NSArray *)SMA2;

@end

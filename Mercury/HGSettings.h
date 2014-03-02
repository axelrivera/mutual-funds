//
//  HGSettings.h
//
//  Created by Axel Rivera on 12/4/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kHGSettingsDetailChartPeriod @"HGSettingsDetailChartPeriod"

FOUNDATION_EXPORT NSUInteger const HGChartHistoricalStartInterval;

FOUNDATION_EXPORT NSUInteger const HGChartPeriodThreeMonthInterval;
FOUNDATION_EXPORT NSUInteger const HGChartPeriodOneYearInterval;
FOUNDATION_EXPORT NSUInteger const HGChartPeriodTenYearInterval;

FOUNDATION_EXPORT NSString * const HGChartPeriodThreeMonthDaily;
FOUNDATION_EXPORT NSString * const HGChartPeriodOneYearDaily;
FOUNDATION_EXPORT NSString * const HGChartPeriodTenYearWeekly;

@interface HGSettings : NSObject

- (NSString *)detailChartPeriod;
- (void)setDetailChartPeriod:(NSString *)chartPeriod;

- (NSUInteger)intervalForChartPeriod:(NSString *)chartPeriod;
- (NSUInteger)SMA1forChartPeriod:(NSString *)chartPeriod;
- (NSUInteger)SMA2forChartPeriod:(NSString *)chartPeriod;

+ (HGSettings *)defaultSettings;

@end

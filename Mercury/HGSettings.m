//
//  RCSettings.m
//  RestClient
//
//  Created by Axel Rivera on 12/4/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import "HGSettings.h"

NSUInteger const HGSingleYearInterval = 365;

NSUInteger const HGChartHistoricalStartInterval = HGSingleYearInterval * 11; // 11 years in days

NSUInteger const HGChartPeriodThreeMonthInterval = 90; // 90 days
NSUInteger const HGChartPeriodOneYearInterval = HGSingleYearInterval;  // 365 days
NSUInteger const HGChartPeriodTenYearInterval = HGSingleYearInterval * 10; // 10 years in days

NSString * const HGChartPeriodThreeMonthDaily = @"HGChartPeriodThreeMonthDaily";
NSString * const HGChartPeriodOneYearDaily = @"HGChartPeriodOneYearDaily";
NSString * const HGChartPeriodTenYearWeekly = @"HGChartPeriodTenYearWeekly";

@implementation HGSettings

#pragma mark - Singleton Methods

- (NSString *)detailChartPeriod
{
    NSString *period = [[NSUserDefaults standardUserDefaults] objectForKey:kHGSettingsDetailChartPeriod];
    if (IsEmpty(period)) {
        period = HGChartPeriodOneYearDaily;
    }
    return period;
}

- (void)setDetailChartPeriod:(NSString *)chartPeriod
{
    [[NSUserDefaults standardUserDefaults] setObject:chartPeriod forKey:kHGSettingsDetailChartPeriod];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSUInteger)intervalForChartPeriod:(NSString *)chartPeriod
{
    NSUInteger period = HGChartPeriodOneYearInterval;
    if ([chartPeriod isEqualToString:HGChartPeriodThreeMonthDaily]) {
        period = HGChartPeriodThreeMonthInterval;
    } else if ([chartPeriod isEqualToString:HGChartPeriodOneYearDaily]) {
        period = HGChartPeriodOneYearInterval;
    } else if ([chartPeriod isEqualToString:HGChartPeriodTenYearWeekly]) {
        period = HGChartPeriodTenYearInterval;
    }
    return period;
}

- (NSUInteger)SMA1forChartPeriod:(NSString *)chartPeriod
{
    NSUInteger sma = 50;
    if ([chartPeriod isEqualToString:HGChartPeriodThreeMonthDaily] ||
        [chartPeriod isEqualToString:HGChartPeriodOneYearDaily])
    {
        sma = 50;
    } else if ([chartPeriod isEqualToString:HGChartPeriodTenYearWeekly]) {
        sma = 10;
    }
    return sma;
}

- (NSUInteger)SMA2forChartPeriod:(NSString *)chartPeriod
{
    NSUInteger sma = 200;
    if ([chartPeriod isEqualToString:HGChartPeriodThreeMonthDaily] ||
        [chartPeriod isEqualToString:HGChartPeriodOneYearDaily])
    {
        sma = 200;
    } else if ([chartPeriod isEqualToString:HGChartPeriodTenYearWeekly]) {
        sma = 40;
    }
    return sma;
}

+ (HGSettings *)defaultSettings
{
    static HGSettings *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[HGSettings alloc] init];
    });
    return shared;
}

@end

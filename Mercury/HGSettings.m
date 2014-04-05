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

NSUInteger const HGChartThreeMonthInterval = 90; // 90 days
NSUInteger const HGChartOneYearInterval = HGSingleYearInterval;  // 365 days
NSUInteger const HGChartTenYearInterval = HGSingleYearInterval * 10; // 10 years in days

NSString * const HGChartRangeThreeMonthDaily = @"HGChartRangeThreeMonthDaily";
NSString * const HGChartRangeOneYearDaily = @"HGChartRangeOneYearDaily";
NSString * const HGChartRangeTenYearWeekly = @"HGChartRangeTenYearWeekly";

@implementation HGSettings

#pragma mark - Singleton Methods

- (NSString *)detailChartRange
{
    NSString *period = [[NSUserDefaults standardUserDefaults] objectForKey:kHGSettingsDetailChartRange];
    if (IsEmpty(period)) {
        period = HGChartRangeThreeMonthDaily;
    }
    return period;
}

- (void)setDetailChartRange:(NSString *)chartRange
{
    [[NSUserDefaults standardUserDefaults] setObject:chartRange forKey:kHGSettingsDetailChartRange];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)fullscreenChartRange
{
    NSString *period = [[NSUserDefaults standardUserDefaults] objectForKey:kHGSettingsFullscreenChartRange];
    if (IsEmpty(period)) {
        period = HGChartRangeOneYearDaily;
    }
    return period;
}

- (void)setFullscreenChartRange:(NSString *)chartRange
{
    [[NSUserDefaults standardUserDefaults] setObject:chartRange forKey:kHGSettingsFullscreenChartRange];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSUInteger)intervalForChartRange:(NSString *)chartPeriod
{
    NSUInteger period = HGChartOneYearInterval;
    if ([chartPeriod isEqualToString:HGChartRangeThreeMonthDaily]) {
        period = HGChartThreeMonthInterval;
    } else if ([chartPeriod isEqualToString:HGChartRangeOneYearDaily]) {
        period = HGChartOneYearInterval;
    } else if ([chartPeriod isEqualToString:HGChartRangeTenYearWeekly]) {
        period = HGChartTenYearInterval;
    }
    return period;
}

- (NSUInteger)SMA1PeriodForChartRange:(NSString *)chartRange
{
    NSUInteger sma = 50;
    if ([chartRange isEqualToString:HGChartRangeThreeMonthDaily] ||
        [chartRange isEqualToString:HGChartRangeOneYearDaily])
    {
        sma = 50;
    } else if ([chartRange isEqualToString:HGChartRangeTenYearWeekly]) {
        sma = 10;
    }
    return sma;
}

- (NSUInteger)SMA2PeriodForChartRange:(NSString *)chartRange
{
    NSUInteger sma = 200;
    if ([chartRange isEqualToString:HGChartRangeThreeMonthDaily] ||
        [chartRange isEqualToString:HGChartRangeOneYearDaily])
    {
        sma = 200;
    } else if ([chartRange isEqualToString:HGChartRangeTenYearWeekly]) {
        sma = 40;
    }
    return sma;
}

- (BOOL)showEquityWarning
{
    NSNumber *equityWarning = [[NSUserDefaults standardUserDefaults] objectForKey:kHGSettingsEquityWarning];
    if (IsEmpty(equityWarning)) {
        equityWarning = @(YES);
    }
    return [equityWarning boolValue];
}

- (void)setShowEquityWarning:(BOOL)equityWarning
{
    [[NSUserDefaults standardUserDefaults] setBool:equityWarning forKey:kHGSettingsEquityWarning];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)guideShown
{
    NSNumber *shown = [[NSUserDefaults standardUserDefaults] objectForKey:kHGSettingsGuideShown];
    if (IsEmpty(shown)) {
        shown = @(NO);
    }
    return [shown boolValue];
}

- (void)setGuideShown:(BOOL)shown
{
    [[NSUserDefaults standardUserDefaults] setBool:shown forKey:kHGSettingsGuideShown];
    [[NSUserDefaults standardUserDefaults] synchronize];
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

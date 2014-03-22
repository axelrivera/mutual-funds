//
//  HGSettings.h
//
//  Created by Axel Rivera on 12/4/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

// Local Settings

#define kHGSettingsDisclaimerShown @"HGSettingsDisclaimerShown"
#define kHGSettingsDetailChartRange @"HGSettingsDetailChartRange"
#define kHGSettingsFullscreenChartRange @"HGSettingsFullscreenChartRange"

FOUNDATION_EXPORT NSUInteger const HGChartHistoricalStartInterval;

FOUNDATION_EXPORT NSUInteger const HGChartThreeMonthInterval;
FOUNDATION_EXPORT NSUInteger const HGChartOneYearInterval;
FOUNDATION_EXPORT NSUInteger const HGChartTenYearInterval;

FOUNDATION_EXPORT NSString * const HGChartRangeThreeMonthDaily;
FOUNDATION_EXPORT NSString * const HGChartRangeOneYearDaily;
FOUNDATION_EXPORT NSString * const HGChartRangeTenYearWeekly;

@interface HGSettings : NSObject

- (NSString *)detailChartRange;
- (void)setDetailChartRange:(NSString *)chartRange;

- (NSString *)fullscreenChartRange;
- (void)setFullscreenChartRange:(NSString *)chartRange;

- (NSUInteger)intervalForChartRange:(NSString *)chartRange;

- (NSUInteger)SMA1PeriodForChartRange:(NSString *)chartRange;
- (NSUInteger)SMA2PeriodForChartRange:(NSString *)chartRange;

- (BOOL)disclaimerShown;
- (void)setDisclaimershown:(BOOL)shown;

+ (HGSettings *)defaultSettings;

@end

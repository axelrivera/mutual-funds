//
//  MercuryBannerManager.h
//  Mercury
//
//  Created by Axel Rivera on 3/19/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <iAd/iAd.h>

FOUNDATION_EXPORT NSString * const HGBannerActionWillBegin;
FOUNDATION_EXPORT NSString * const HGBannerActionDidFinish;

@interface MercuryBannerManager : NSObject <ADBannerViewDelegate>

@property (strong, nonatomic, readonly) ADBannerView *bannerView;

+ (MercuryBannerManager *)sharedInstance;

- (void)addBannerViewController:(id)controller;
- (void)removeBannerViewController:(id)controller;

- (void)hideBanner;

@end
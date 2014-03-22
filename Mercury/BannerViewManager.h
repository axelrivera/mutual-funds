//
//  BannerViewManager.h
//  Mercury
//
//  Created by Axel Rivera on 3/19/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <iAd/iAd.h>

FOUNDATION_EXPORT NSString * const BannerViewActionWillBegin;
FOUNDATION_EXPORT NSString * const BannerViewActionDidFinish;

@interface BannerViewManager : NSObject <ADBannerViewDelegate>

@property (strong, nonatomic, readonly) ADBannerView *bannerView;

+ (BannerViewManager *)sharedInstance;

- (void)addBannerViewController:(id)controller;
- (void)removeBannerViewController:(id)controller;

- (void)hideBanner;

@end
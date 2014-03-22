//
//  MercuryBannerManager.m
//  Mercury
//
//  Created by Axel Rivera on 3/19/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "MercuryBannerManager.h"

#import "PositionsViewController.h"

NSString * const HGBannerActionWillBegin = @"HGBannerActionWillBegin";
NSString * const HGBannerActionDidFinish = @"HGBannerActionDidFinish";

@interface MercuryBannerManager ()

@property (strong, nonatomic, readwrite) ADBannerView *bannerView;
@property (strong, nonatomic) NSMutableSet *bannerViewControllers;

@end

@implementation MercuryBannerManager

+ (MercuryBannerManager *)sharedInstance
{
    static MercuryBannerManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        if (![[MercuryStoreManager sharedInstance] purchasedAdRemoval]) {
            DLog(@"Initializing Banner View!!");
            _bannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
            _bannerView.delegate = self;
        } else {
            DLog(@"Advertising Disabled!!");
        }
        
        _bannerViewControllers = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)addBannerViewController:(id)controller
{
    [self.bannerViewControllers addObject:controller];
}

- (void)removeBannerViewController:(id)controller
{
    [self.bannerViewControllers removeObject:controller];
}

- (void)hideBanner
{
    self.bannerView.hidden = YES;
    for (id bvc in self.bannerViewControllers) {
        [bvc updateLayout];
    }
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (![[MercuryStoreManager sharedInstance] purchasedAdRemoval]) {
        for (id bvc in self.bannerViewControllers) {
            [bvc updateLayout];
        }
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    if (![[MercuryStoreManager sharedInstance] purchasedAdRemoval]) {
        for (id bvc in self.bannerViewControllers) {
            [bvc updateLayout];
        }
    }
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    [[NSNotificationCenter defaultCenter] postNotificationName:HGBannerActionWillBegin object:self];
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    [[NSNotificationCenter defaultCenter] postNotificationName:HGBannerActionDidFinish object:self];
}

@end


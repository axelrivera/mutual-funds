//
//  BannerViewManager.m
//  Mercury
//
//  Created by Axel Rivera on 3/19/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "BannerViewManager.h"

#import "PositionsViewController.h"

NSString * const BannerViewActionWillBegin = @"BannerViewActionWillBegin";
NSString * const BannerViewActionDidFinish = @"BannerViewActionDidFinish";

@interface BannerViewManager ()

@property (strong, nonatomic, readwrite) ADBannerView *bannerView;
@property (strong, nonatomic) NSMutableSet *bannerViewControllers;

@end

@implementation BannerViewManager

+ (BannerViewManager *)sharedInstance
{
    static BannerViewManager *sharedInstance = nil;
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
    [[NSNotificationCenter defaultCenter] postNotificationName:BannerViewActionWillBegin object:self];
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    [[NSNotificationCenter defaultCenter] postNotificationName:BannerViewActionDidFinish object:self];
}

@end


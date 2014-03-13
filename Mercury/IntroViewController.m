//
//  IntroViewController.m
//  Mercury
//
//  Created by Axel Rivera on 3/11/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "IntroViewController.h"

#import <UIView+AutoLayout.h>
#import "GHWalkThroughView.h"
#import "GHWalkThroughPageCell.h"


@interface IntroViewController () <GHWalkThroughViewDataSource, GHWalkThroughViewDelegate>

@property (strong, nonatomic) GHWalkThroughView *introView;

@end

@implementation IntroViewController

- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.title = @"Introduction";
    }
    return self;
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:CGRectZero];
    self.view.backgroundColor = [UIColor hg_highlightColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    UILabel *introLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0,
                                                                    0.0,
                                                                    self.view.frame.size.width - 20.0,
                                                                    50.0)];
    introLabel.text = @"GUIDE";
    introLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:40.0];
    introLabel.textColor = [UIColor whiteColor];
    introLabel.textAlignment = NSTextAlignmentCenter;
    
    self.introView = [[GHWalkThroughView alloc] initWithFrame:self.view.bounds];
    self.introView.floatingHeaderView = introLabel;
    self.introView.backgroundColor = [UIColor hg_highlightColor];
    self.introView.walkThroughDirection = GHWalkThroughViewDirectionHorizontal;
    self.introView.dataSource = self;
    self.introView.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.introView.frame = self.view.bounds;
    [self.introView showInView:self.view animateDuration:0.0];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - GHWalkThroughViewDataSource Methods

- (NSInteger)numberOfPages
{
    return 7;
}

- (UIImage *)bgImageforPage:(NSInteger)index
{
    return nil;
}

- (void)configurePage:(GHWalkThroughPageCell *)cell atIndex:(NSInteger)index
{
    NSString *title = nil;
    NSString *desc = nil;
    NSString *imageName = nil;
    
    if (index == 0) {
        title = @"DISCLAIMER";
        desc =
        @"Trading any type of securities always carries an element of risk. Mutual Fund Signals does not recommend buying or "
        "selling of particular securities, but assists in making a desicion. ALWAYS supplement the given signals with "
        "additional research to get optimal returns. THE DEVELOPER IS NOT LIABLE FOR ANY DAMAGES INCURRED FROM THE USE OR "
        "THE INABILITY TO USE THE APP.";
        cell.titlePositionY = 400.0;
        cell.descPositionY = 380.0;
    } else if (index == 1) {
        title = @"MUTUAL FUND SIGNALS";
        desc =
        @"The App uses Simple Moving Averages to generate buy and sell signals for Mutual Funds and ETFs. "
        "This method is ONLY RECOMMENDED FOR LONG TERM POSITIONS because signals are generated on average once a year or longer. "
        "This method SHOULD NOT be used with STOCKS because they are too volatile to generate accurate signals.";
        cell.titlePositionY = 400.0;
        cell.descPositionY = 380.0;
    } else if (index == 2) {
        title = @"BULLISH MARKETS";
        desc =
        @"The 200-day moving average is a popular, quantified, long-term trend indicator. "
        "Markets trading above the 200-day moving average tend to be in longer term uptrends. ";
        imageName = @"bullish_signal";
        cell.titlePositionY = 250.0;
        cell.descPositionY = 230.0;
    } else if (index == 3) {
        title = @"BEARISH MARKETS";
        desc =
        @"Markets trading below the 200-day moving average tend to be in longer term downtrends.";
        imageName = @"bearish_signal";
        cell.titlePositionY = 250.0;
        cell.descPositionY = 230.0;
    } else if (index == 4) {
        title = @"BUY SIGNALS";
        desc =
        @"A BUY signal is generated when the 50-day moving average closes ABOVE the 200-day moving average. "
        "Also, the 200-day moving average should have an up angle.";
        imageName = @"buy_signal";
        cell.titlePositionY = 250.0;
        cell.descPositionY = 230.0;
    } else if (index == 5) {
        title = @"SELL SIGNALS";
        desc =
        @"A SELL signal is generated when the 50-day moving average closes BELOW the 200-day moving average.";
        imageName = @"buy_signal";
        cell.titlePositionY = 250.0;
        cell.descPositionY = 230.0;
    } else if (index == 6) {
        title = @"FALSE SIGNALS";
        desc =
        @"Moving Averages don't provide accurate signals when both 50-day and 200-day are moving sideways. "
        "In such a case, you should do additional research to confirm the signal and take action.";
        imageName = @"sideways_signal";
        cell.titlePositionY = 250.0;
        cell.descPositionY = 230.0;
    }
    
    cell.title = title;
    cell.titleImage = [UIImage imageNamed:imageName];
    cell.desc = desc;
}

- (void)walkthroughDidDismissView:(GHWalkThroughView *)walkthroughView
{
    [[HGSettings defaultSettings] setDisclaimershown:YES];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end

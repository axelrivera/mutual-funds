//
//  GuideViewController.m
//  Mercury
//
//  Created by Axel Rivera on 3/22/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "GuideViewController.h"

#import "GuideContentView.h"
#import "UIViewController+Layout.h"
#import <UIView+AutoLayout.h>

#import "IntroGuideView.h"
#import "BullGuideView.h"
#import "BearGuideView.h"
#import "BuyGuideView.h"
#import "SellGuideView.h"
#import "FalseGuideView.h"

@interface GuideViewController ()

@end

@implementation GuideViewController

+ (NSArray *)defaultPanels
{
    return @[ [IntroGuideView panel],
              [BullGuideView panel],
              [BearGuideView panel],
              [BuyGuideView panel],
              [SellGuideView panel],
              [FalseGuideView panel] ];
}

+ (instancetype)defaultGuideViewController
{
    GuideViewController *controller = [[[self class] alloc] initWithPanels:[[self class] defaultPanels] skip:NO];
    return controller;
}

+ (instancetype)skipGuideViewController
{
    GuideViewController *controller = [[[self class] alloc] initWithPanels:[[self class] defaultPanels] skip:YES];
    return controller;
}

- (instancetype)init
{
    return [self initWithPanels:@[] skip:NO];
}

- (instancetype)initWithPanels:(NSArray *)panels skip:(BOOL)skip
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.title = @"Guide";
        _panels = panels;
        _skipEnabled = skip;
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

    self.guideView = [[GuideContentView alloc] initWithCellViews:self.panels frame:CGRectZero];
    self.guideView.translatesAutoresizingMaskIntoConstraints = NO;

    __weak GuideViewController *weakSelf = self;

    self.guideView.completionBlock = ^{
        [weakSelf.navigationController dismissViewControllerAnimated:YES completion:nil];
    };

    if (self.skipEnabled) {
        self.guideView.skipBlock = ^{
            [weakSelf.navigationController dismissViewControllerAnimated:YES completion:nil];
        };
    }

    [self.view addSubview:self.guideView];
}

- (void)viewDidLayoutSubviews
{
    [self.guideView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(self.topOrigin, 0.0, 0.0, 0.0)];

    [self.view layoutSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

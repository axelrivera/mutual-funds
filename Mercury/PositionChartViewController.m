//
//  PositionChartViewController.m
//  Mercury
//
//  Created by Axel Rivera on 2/22/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "PositionChartViewController.h"

#import <UIView+AutoLayout.h>
#import <NCIChartView.h>

@interface PositionChartViewController ()

@end

@implementation PositionChartViewController

- (instancetype)initWithTicker:(HGTicker *)ticker
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _ticker = ticker;
        _dataSource = @[];
    }
    return self;
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:CGRectZero];
    self.view.backgroundColor = [UIColor hg_mainBackgroundColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.chartView = [[NCISimpleChartView alloc]
                      initWithFrame:CGRectZero
                      andOptions: @{nciIsFill: @(NO),
                                    nciSelPointSizes: @[@5, @10, @5]}];
    self.chartView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.chartView];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self.chartView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    
    [self.view layoutSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    dispatch_queue_t backgroundQueue = dispatch_queue_create("me.axelrivera.myqueue", 0);
    dispatch_async(backgroundQueue, ^{
        self.dataSource = [self.ticker.position chartArrayForInterval:365 SMA1:50 SMA2:200];
        dispatch_async(dispatch_get_main_queue(), ^{
            for (NSInteger i = 0; i < [self.dataSource count]; i++) {
                NSDictionary *dictionary = self.dataSource[i];
                [self.chartView addPoint:(double)i val:@[ dictionary[@"close"], dictionary[@"sma1"], dictionary[@"sma2"] ]];
            }
            [self.chartView drawChart];
        });
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    if ([UIDevice currentDevice].orientation == UIInterfaceOrientationPortrait) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return NO;
    }
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
//{
//    if ([UIDevice currentDevice].orientation == UIInterfaceOrientationLandscapeLeft) {
//        return UIInterfaceOrientationLandscapeLeft;
//    } else {
//        return UIInterfaceOrientationLandscapeLeft;
//    }
//}

@end

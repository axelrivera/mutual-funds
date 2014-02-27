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
                                    nciLineColors: @[HexColor(0x204A87), HexColor(0x5C3566), HexColor(0xCE5C00)],
                                    nciLineWidths: @[@1, [NSNull null]],
                                    nciUseDateFormatter: @(YES),
                                    nciHasSelection: @(NO)}];
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
    
    [self.ticker.position calculateChartForInterval:365 SMA1:50 SMA2:200 completion:^(NSArray *chartArray) {
        self.dataSource = chartArray;
        for (NSInteger i = 0; i < [self.dataSource count]; i++) {
            NSDictionary *dictionary = self.dataSource[i];
            
            NSDate *date = dictionary[@"date"];
            NSTimeInterval dateInterval = [date timeIntervalSince1970];
            
            [self.chartView addPoint:dateInterval val:@[ dictionary[@"close"], dictionary[@"sma1"], dictionary[@"sma2"] ]];
        }
        [self.chartView drawChart];
    }];
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

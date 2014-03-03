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

- (instancetype)initWithTicker:(HGTicker *)ticker chartArray:(NSArray *)chartArray
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _ticker = ticker;
        _chartArray = chartArray;
        _currentPeriod = HGChartPeriodTenYearWeekly;
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
    
    NSDate *startDate = [NSDate chartStartDateForInterval:[[HGSettings defaultSettings] intervalForChartPeriod:self.currentPeriod]];
    
    DLog(@"Chart Array: %@", self.chartArray);
    
    self.dataSource = [self.chartArray chartWeeklyArrayWithStartDate:startDate];
    
	self.chartView = [[NCISimpleChartView alloc]
                      initWithFrame:CGRectZero
                      andOptions: @{nciIsFill: @(NO),
                                    nciLineColors: @[[UIColor hg_closeColor], [UIColor hg_SMA1Color], [UIColor hg_SMA2Color]],
                                    nciLineWidths: @[@1, [NSNull null]],
                                    nciUseDateFormatter: @(YES),
                                    nciHasSelection: @(NO),
                                    nciXLabelsDistance: @100,
                                    nciGridLeftMargin: @40,
                                    nciXLabelsFont: [UIFont systemFontOfSize:8.0],
                                    nciYLabelsFont: [UIFont systemFontOfSize:8.0],
                                    nciGridHorizontal: [[NCILine alloc] initWithWidth:0.5 color:[UIColor colorWithWhite:0.5 alpha:0.3] andDashes:@[@1, @1]],
                                    nciGridVertical: [[NCILine alloc] initWithWidth:0.0 color:[UIColor clearColor] andDashes:nil]}];
    self.chartView.translatesAutoresizingMaskIntoConstraints = NO;
    
    for (NSInteger i = 0; i < [self.dataSource count]; i++) {
        NSDictionary *dictionary = self.dataSource[i];
        
        NSDate *date = dictionary[@"date"];
        NSTimeInterval dateInterval = [date timeIntervalSince1970];
        
        [self.chartView addPoint:dateInterval val:@[ dictionary[@"close"], dictionary[@"sma1"], dictionary[@"sma2"] ]];
    }
    [self.chartView drawChart];
    
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    if ([UIDevice currentDevice].orientation == UIInterfaceOrientationPortrait) {
        if (self.completionBlock) {
            self.completionBlock();
        }
        return NO;
    }
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

@end

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
        _dataSource = [[ticker.position.historyArray subarrayWithRange:NSMakeRange(0, 365)] reversedArray];
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
    
    for (NSInteger i = 0; i < [self.dataSource count]; i++) {
        HGHistory * history = self.dataSource[i];
        [self.chartView addPoint:(double)i val:@[ history.close, [history sma1Value], [history sma2Value] ]];
    }
    
    [self.chartView drawChart];
    
//    int numOfPoints = 10;
//    for (int ind = 0; ind < numOfPoints; ind ++){
//        [self.chartView addPoint:ind val:@[@(arc4random() % 5)]];
//    }
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        for (int ind = numOfPoints; ind < 4*numOfPoints; ind ++){
//            [NSThread sleepForTimeInterval:2.0f];
//            [self.chartView addPoint:ind val:@[@(2*ind)]];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.chartView drawChart];
//            });
//        }
//    });
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

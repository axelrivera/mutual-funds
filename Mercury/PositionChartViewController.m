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

@property (strong, nonatomic) UILabel *legendLabel;

@property (strong, nonatomic) NSString *chartPeriod;

- (void)setupFooterView;

- (void)updateLegend;
- (void)updateName;
- (void)updateDate;

@end

@implementation PositionChartViewController

- (instancetype)initWithTicker:(HGTicker *)ticker chartArray:(NSArray *)chartArray
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _ticker = ticker;
        _chartArray = chartArray;
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
    
    NSString *(^SelectionRenderBlock)(double, NSArray *) = ^(double argument, NSArray *values) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:argument];
        NSString *dateStr = [[NSDateFormatter hg_lastTradeDateFormatter] stringFromDate:date];
        
        NSString *close = @"N/A";
        NSString *sma1 = @"N/A";
        NSString *sma2 = @"N/A";
        
        if ([values[0] isKindOfClass:[NSNumber class]]) {
            close = [NSString stringWithFormat:@"%.2f", [values[0] floatValue]];
        }
        
        if ([values[1] isKindOfClass:[NSNumber class]]) {
            sma1 = [NSString stringWithFormat:@"%.2f", [values[1] floatValue]];
        }
        
        if ([values[2] isKindOfClass:[NSNumber class]]) {
            sma2 = [NSString stringWithFormat:@"%.2f", [values[2] floatValue]];
        }
        
        NSUInteger sma1Interval = [[HGSettings defaultSettings] SMA1forChartPeriod:self.chartPeriod];
        NSUInteger sma2Interval = [[HGSettings defaultSettings] SMA2forChartPeriod:self.chartPeriod];
        
        NSString *sma1Pfx = [NSString stringWithFormat:@"sma(%lu)", (unsigned long)sma1Interval];
        NSString *sma2Pfx = [NSString stringWithFormat:@"sma(%lu)", (unsigned long)sma2Interval];
        
        return [NSString stringWithFormat:@"close = %@, %@ = %@, %@ = %@, %@",
                close, sma1Pfx, sma1, sma2Pfx, sma2, dateStr];
    };
    
	self.chartView = [[NCISimpleChartView alloc]
                      initWithFrame:CGRectZero
                      andOptions: @{nciIsFill: @(NO),
                                    nciLineColors: @[[UIColor hg_closeColor], [UIColor hg_SMA1Color], [UIColor hg_SMA2Color]],
                                    nciLineWidths: @[@1, [NSNull null]],
                                    nciUseDateFormatter: @(YES),
                                    nciHasSelection: @(YES),
                                    nciXLabelsDistance: @100,
                                    nciGridTopMargin: @44,
                                    nciGridLeftMargin: @40,
                                    nciSelPointSizes: @[@5, [NSNull null]],
                                    nciSelPointColors: @[ [[UIColor hg_closeColor] colorWithAlphaComponent:0.7], [[UIColor hg_SMA1Color] colorWithAlphaComponent:0.7], [[UIColor hg_SMA2Color] colorWithAlphaComponent:0.7] ],
                                    nciSelPointFont: [UIFont systemFontOfSize:10.0],
                                    nciSelPointFontColor: [UIColor darkGrayColor],
                                    nciSelPointTextRenderer:SelectionRenderBlock,
                                    nciXLabelsFont: [UIFont systemFontOfSize:8.0],
                                    nciYLabelsFont: [UIFont systemFontOfSize:8.0],
                                    nciGridHorizontal: [[NCILine alloc] initWithWidth:0.5 color:[UIColor colorWithWhite:0.5 alpha:0.3] andDashes:@[@1, @1]],
                                    nciGridVertical: [[NCILine alloc] initWithWidth:0.0 color:[UIColor clearColor] andDashes:nil]}];
    self.chartView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:self.chartView];
    
    self.legendLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.legendLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.legendLabel.font = [UIFont systemFontOfSize:10.0];
    self.legendLabel.backgroundColor = [UIColor clearColor];
    self.legendLabel.textAlignment = NSTextAlignmentRight;
    
    [self.legendLabel autoSetDimension:ALDimensionHeight toSize:14.0];
    
    [self.view addSubview:self.legendLabel];
    
    [self setupFooterView];
    
    [self updateName];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self.chartView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0.0];
    [self.chartView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0.0];
    [self.chartView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10.0];
    [self.chartView autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self.footerView];
    
    [self.legendLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:15.0];
    [self.legendLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:25.0];
    
    [self.footerView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0.0];
    [self.footerView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0.0];
    [self.footerView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0.0];
    
    [self.view layoutSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarHidden = YES;
    
    if ([[[HGSettings defaultSettings] fullscreenChartPeriod] isEqualToString:HGChartPeriodThreeMonthDaily]) {
        self.segmentedControl.selectedSegmentIndex = 0;
    } else if ([[[HGSettings defaultSettings] fullscreenChartPeriod] isEqualToString:HGChartPeriodOneYearDaily]) {
        self.segmentedControl.selectedSegmentIndex = 1;
    } else {
        self.segmentedControl.selectedSegmentIndex = 2;
    }
    
    [self segmentedControlChanged:self.segmentedControl];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
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

#pragma mark - Private Methods

- (void)setupFooterView
{
    self.footerView = [[UIView alloc] initWithFrame:CGRectZero];
    self.footerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.footerView.backgroundColor = [UIColor hg_barBackgroundColor];
    
    [self.footerView autoSetDimension:ALDimensionHeight toSize:44.0];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectZero];
    lineView.translatesAutoresizingMaskIntoConstraints = NO;
    lineView.backgroundColor = [UIColor hg_tableSeparatorColor];
    
    [lineView autoSetDimension:ALDimensionHeight toSize:0.5];
    
    [self.footerView addSubview:lineView];
    
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.nameLabel.font = [UIFont systemFontOfSize:14.0];
    self.nameLabel.textColor = [UIColor blackColor];
    self.nameLabel.backgroundColor = [UIColor clearColor];
    
    [self.nameLabel autoSetDimension:ALDimensionHeight toSize:20.0];
    
    [self.footerView addSubview:self.nameLabel];
    
    self.dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.dateLabel.font = [UIFont systemFontOfSize:10.0];
    self.dateLabel.textColor = [UIColor darkGrayColor];
    self.dateLabel.backgroundColor = [UIColor clearColor];
    
    [self.dateLabel autoSetDimension:ALDimensionHeight toSize:14.0];
    
    [self.footerView addSubview:self.dateLabel];
    
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[ @"3M", @"1Y", @"10Y" ]];
    self.segmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
    [self.segmentedControl setWidth:60.0 forSegmentAtIndex:0];
    [self.segmentedControl setWidth:60.0 forSegmentAtIndex:1];
    [self.segmentedControl setWidth:60.0 forSegmentAtIndex:2];
    
    [self.segmentedControl addTarget:self
                              action:@selector(segmentedControlChanged:)
                    forControlEvents:UIControlEventValueChanged];
    
    [self.footerView addSubview:self.segmentedControl];
    
    [lineView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0.0];
    [lineView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0.0];
    [lineView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0.0];
    
    [self.segmentedControl autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10.0];
    [self.segmentedControl autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    [self.nameLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:5.0];
    [self.nameLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10.0];
    [self.nameLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10.0 + self.segmentedControl.frame.size.width + 10.0];
    
    [self.dateLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:5.0];
    [self.dateLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10.0];
    [self.dateLabel autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.nameLabel];
    
    [self.view addSubview:self.footerView];
}

- (void)updateLegend
{
    NSUInteger sma1Interval = [[HGSettings defaultSettings] SMA1forChartPeriod:self.chartPeriod];
    NSUInteger sma2Interval = [[HGSettings defaultSettings] SMA2forChartPeriod:self.chartPeriod];
    
    NSString *sma1 = [NSString stringWithFormat:@"sma(%lu)", (unsigned long)sma1Interval];
    NSString *sma2 = [NSString stringWithFormat:@"sma(%lu)", (unsigned long)sma2Interval];
    NSString *legenStr = [NSString stringWithFormat:@"%@  %@", sma1, sma2];
    
    NSRange sma1Range = [legenStr rangeOfString:sma1];
    NSRange sma2Range = [legenStr rangeOfString:sma2];
    
    NSMutableAttributedString *legendAttributedStr = [[NSMutableAttributedString alloc] initWithString:legenStr];
    [legendAttributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor hg_SMA1Color] range:sma1Range];
    [legendAttributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor hg_SMA2Color] range:sma2Range];
    
    self.legendLabel.attributedText = legendAttributedStr;
}

- (void)updateName
{
    self.nameLabel.text = [NSString stringWithFormat:@"%@ (%@)", self.ticker.position.name, self.ticker.position.symbol];
}

- (void)updateDate
{
    if (!IsEmpty(self.dataSource) && [self.dataSource count] >= 2) {
        NSDate *startDate = self.dataSource.firstObject[@"date"];
        NSDate *endDate = self.dataSource.lastObject[@"date"];
        
        NSString *startDateStr = [[NSDateFormatter hg_chartDateFormatter] stringFromDate:startDate];
        NSString *endDateStr = [[NSDateFormatter hg_chartDateFormatter] stringFromDate:endDate];
        
        self.dateLabel.text = [NSString stringWithFormat:@"%@ to %@", startDateStr, endDateStr];
    } else {
        self.dateLabel.text = @"";
    }
}

#pragma mark - Selector Methods

- (void)segmentedControlChanged:(UISegmentedControl *)segmentedControl
{
    dispatch_queue_t backgroundQueue = dispatch_queue_create(kMercuryDispatchQueue, NULL);
    dispatch_async(backgroundQueue, ^{
        NSDate *startDate = nil;
        if (segmentedControl.selectedSegmentIndex == 0) {
            self.chartPeriod = HGChartPeriodThreeMonthDaily;
            startDate = [NSDate chartStartDateForInterval:[[HGSettings defaultSettings] intervalForChartPeriod:self.chartPeriod]];
            self.dataSource = [self.chartArray chartDailyArrayWithStartDate:startDate];
        } else if (segmentedControl.selectedSegmentIndex == 1) {
            self.chartPeriod = HGChartPeriodOneYearDaily;
            startDate = [NSDate chartStartDateForInterval:[[HGSettings defaultSettings] intervalForChartPeriod:self.chartPeriod]];
            self.dataSource = [self.chartArray chartDailyArrayWithStartDate:startDate];
        } else {
            self.chartPeriod = HGChartPeriodTenYearWeekly;
            startDate = [NSDate chartStartDateForInterval:[[HGSettings defaultSettings] intervalForChartPeriod:self.chartPeriod]];
            self.dataSource = [self.chartArray chartWeeklyArrayWithStartDate:startDate];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateDate];
            [self updateLegend];
            
            if (!IsEmpty(self.chartView.chartData)) {
                [self.chartView.chartData removeAllObjects];
            }
            
            for (NSInteger i = 0; i < [self.dataSource count]; i++) {
                NSDictionary *dictionary = self.dataSource[i];
                
                NSDate *date = dictionary[@"date"];
                NSTimeInterval dateInterval = [date timeIntervalSince1970];
                
                [self.chartView addPoint:dateInterval val:@[ dictionary[@"close"], dictionary[@"sma1"], dictionary[@"sma2"] ]];
            }
            
            [self.chartView drawChart];
        });
    });
}

@end

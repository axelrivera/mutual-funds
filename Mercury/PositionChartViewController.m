//
//  PositionChartViewController.m
//  Mercury
//
//  Created by Axel Rivera on 2/22/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "PositionChartViewController.h"

#import <UIView+AutoLayout.h>
#import <LineChart.h>
#import <MBProgressHUD.h>

@interface PositionChartViewController ()

@property (strong, nonatomic) MBProgressHUD *hud;
@property (strong, nonatomic) UILabel *legendLabel;

@property (strong, nonatomic) NSString *chartRange;

- (void)setupFooterView;

- (void)fetchData;
- (void)reloadChart;
- (void)updateLegend;
- (void)updateName;
- (void)updateDateWithStart:(NSDate *)startDate end:(NSDate *)endDate;

@end

@implementation PositionChartViewController

- (instancetype)initWithTicker:(HGTicker *)ticker
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.title = @"Fullscreen Chart";
        _ticker = ticker;
        _history = @[];
        _SMA1 = @[];
        _SMA2 = @[];
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
    
    self.chartView = [[LCLineChartView alloc] initWithFrame:CGRectZero];
    self.chartView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.chartView showLegend:NO animated:NO];
    
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
    [self.chartView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0.0];
    [self.chartView autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self.footerView];
    
    [self.legendLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:15.0];
    [self.legendLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:40.0];
    
    [self.footerView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0.0];
    [self.footerView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0.0];
    [self.footerView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0.0];
    
    [self.view layoutSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarHidden = YES;
    
    if ([[[HGSettings defaultSettings] fullscreenChartRange] isEqualToString:HGChartRangeThreeMonthDaily]) {
        self.segmentedControl.selectedSegmentIndex = 0;
    } else if ([[[HGSettings defaultSettings] fullscreenChartRange] isEqualToString:HGChartRangeOneYearDaily]) {
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

- (void)fetchData
{
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.hud setLabelText:@"Loading Chart"];
    
    [self.ticker.position historyForChartRange:self.chartRange
                                         block:^(NSArray *history, NSArray *SMA1, NSArray *SMA2)
     {
         if ([history count] < 2) {
             [self.hud hide:YES];
             return;
         }
         
         self.history = history;
         self.SMA1 = SMA1;
         self.SMA2 = SMA2;
         
         [self reloadChart];
     }];
}

- (void)reloadChart
{
    [self updateLegend];
    
    NSDate *startDate = [(HGHistory *)self.history.lastObject date];
    NSDate *endDate = [(HGHistory *)self.history.firstObject date];
    
    [self updateDateWithStart:startDate end:endDate];
    
    NSTimeInterval minX = [startDate timeIntervalSince1970];
    NSTimeInterval maxX = [endDate timeIntervalSince1970];
    
    NSMutableArray *chartData = [@[] mutableCopy];
    
    LCLineChartData *closeData = [[LCLineChartData alloc] init];
    closeData.title = self.ticker.symbol;
    closeData.color = [UIColor hg_closeColor];
    closeData.lineWidth = 0.75;
    closeData.xMin = minX;
    closeData.xMax = maxX;
    closeData.itemCount = [self.history count];
    
    closeData.getData = ^(NSUInteger item) {
        HGHistory *current = self.history[item];
        NSDate *date = current.date;
        NSTimeInterval dateInterval = [date timeIntervalSince1970];
        
        return [LCLineChartDataItem dataItemWithX:dateInterval
                                                y:[current.close floatValue]
                                           xLabel:[[NSDateFormatter hg_lastTradeDateFormatter] stringFromDate:date]
                                        dataLabel:[NSString stringWithFormat:@"%.02f", [current.close floatValue]]];
    };
    
    [chartData addObject:closeData];
    
    if (!IsEmpty(self.SMA1)) {
        NSString *title = [NSString stringWithFormat:@"sma(%ld)",
                           (unsigned long)[[HGSettings defaultSettings] SMA1PeriodForChartRange:HGChartRangeOneYearDaily]];
        
        LCLineChartData *SMAData = [[LCLineChartData alloc] init];
        SMAData.title = title;
        SMAData.color = [UIColor hg_SMA1Color];
        SMAData.smoothPlot = YES;
        SMAData.lineWidth = 0.75;
        SMAData.xMin = minX;
        SMAData.xMax = maxX;
        SMAData.itemCount = [self.SMA1 count];
        
        SMAData.getData = ^(NSUInteger item) {
            HGSMAValue *current = self.SMA1[item];
            NSDate *date = current.date;
            NSTimeInterval dateInterval = [date timeIntervalSince1970];
            
            return [LCLineChartDataItem dataItemWithX:dateInterval
                                                    y:[current.SMA floatValue]
                                               xLabel:[[NSDateFormatter hg_lastTradeDateFormatter] stringFromDate:date]
                                            dataLabel:[NSString stringWithFormat:@"%.02f", [current.SMA floatValue]]];
        };
        
        [chartData addObject:SMAData];
    }
    
    if (!IsEmpty(self.SMA2)) {
        NSString *title = [NSString stringWithFormat:@"sma(%ld)",
                           (unsigned long)[[HGSettings defaultSettings] SMA2PeriodForChartRange:HGChartRangeOneYearDaily]];
        
        LCLineChartData *SMAData = [[LCLineChartData alloc] init];
        SMAData.title = title;
        SMAData.color = [UIColor hg_SMA2Color];
        SMAData.smoothPlot = YES;
        SMAData.lineWidth = 0.75;
        SMAData.xMin = minX;
        SMAData.xMax = maxX;
        SMAData.itemCount = [self.SMA2 count];
        
        SMAData.getData = ^(NSUInteger item) {
            HGSMAValue *current = self.SMA2[item];
            NSDate *date = current.date;
            NSTimeInterval dateInterval = [date timeIntervalSince1970];
            
            return [LCLineChartDataItem dataItemWithX:dateInterval
                                                    y:[current.SMA floatValue]
                                               xLabel:[[NSDateFormatter hg_lastTradeDateFormatter] stringFromDate:date]
                                            dataLabel:[NSString stringWithFormat:@"%.02f", [current.SMA floatValue]]];
        };
        
        [chartData addObject:SMAData];
    }
    
    NSDictionary *yRange = [NSArray hg_minimumAndMaximumRangeForHistory:self.history
                                                                   SMA1:self.SMA1
                                                                   SMA2:self.SMA2];
    
    NSArray *xSteps = @[];
    if ([self.chartRange isEqualToString:HGChartRangeTenYearWeekly]) {
        xSteps = [NSArray hg_xStepsInYearsForHistory:self.history];
    } else {
        xSteps = [NSArray hg_xStepsInMonthsForHistory:self.history];
    }
    
    self.chartView.yMin = [yRange[@"min"] doubleValue];
    self.chartView.yMax = [yRange[@"max"] doubleValue];
    self.chartView.xMin = minX;
    self.chartView.xMax = maxX;
    self.chartView.smoothPlot = NO;
    self.chartView.drawsDataLines = YES;
    self.chartView.drawsDataPoints = NO;
    self.chartView.enableIndicator = NO;
    self.chartView.scaleFont = [UIFont systemFontOfSize:8.0];
    self.chartView.ySteps = [NSArray hg_yStepsForFullscreenChartIncluding:self.history SMA1:self.SMA1 SMA2:self.SMA2];
    self.chartView.xSteps = xSteps;
    self.chartView.data = chartData;
    
    [self.hud hide:YES];
}

- (void)updateLegend
{
    NSUInteger sma1Interval = [[HGSettings defaultSettings] SMA1PeriodForChartRange:self.chartRange];
    NSUInteger sma2Interval = [[HGSettings defaultSettings] SMA2PeriodForChartRange:self.chartRange];
    
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

- (void)updateDateWithStart:(NSDate *)startDate end:(NSDate *)endDate
{
    if (startDate && endDate) {
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
    if (segmentedControl.selectedSegmentIndex == 0) {
        self.chartRange = HGChartRangeThreeMonthDaily;
    } else if (segmentedControl.selectedSegmentIndex == 1) {
        self.chartRange = HGChartRangeOneYearDaily;
    } else {
        self.chartRange = HGChartRangeTenYearWeekly;
    }
    
    [Flurry logEvent:kAnalyticsSelectFullChartRange withParameters:@{ kAnalyticsParameterKeyType : self.chartRange }];
    
    [self fetchData];
}

@end

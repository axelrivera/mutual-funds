//
//  PositionDetailViewController.m
//  Mercury
//
//  Created by Axel Rivera on 2/22/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "PositionDetailViewController.h"

#import <UIView+AutoLayout.h>
#import "UIViewController+Layout.h"

#import "PositionChartViewController.h"
#import "PositionSummaryCell.h"
#import "SignalStatusCell.h"
#import <LineChart.h>
#import <MBProgressHUD.h>

static const CGFloat ContainerChartPaddingTop = 10.0;
static const CGFloat ContainerChartPaddingMiddle = 10.0;
static const CGFloat ContainerLabelHeight = 16.0;
static const CGFloat ContainerChartHeight = 135.0;
static const CGFloat ContainerHeight = (ContainerChartPaddingTop +
                                        ContainerLabelHeight +
                                        ContainerChartPaddingMiddle +
                                        ContainerChartHeight);

@interface PositionDetailViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIBarButtonItem *nextItem;
@property (strong, nonatomic) UIBarButtonItem *prevItem;

@property (strong, nonatomic) UIView *chartContainerView;
@property (strong, nonatomic) UILabel *chartLabel;
@property (strong, nonatomic) UILabel *chartLegendLabel;
@property (strong, nonatomic) UIView *chartTopLine;

@property (strong, nonatomic) NSLayoutConstraint *chartConstraint;
@property (assign, nonatomic) CGFloat chartBottom;

@property (strong, nonatomic) MBProgressHUD *hud;

- (void)updateDataSourceWithSignals:(BOOL)signals reloadTable:(BOOL)reloadTable animated:(BOOL)animated;
- (void)reloadChart;

- (void)setupChartContainerView;
- (void)updatePreviousNext;
- (void)updateViewControllers;

@end

@implementation PositionDetailViewController

- (instancetype)initWithTicker:(HGTicker *)ticker
{
    return [self initWithTicker:ticker allowSave:NO];
}

- (instancetype)initWithTicker:(HGTicker *)ticker allowSave:(BOOL)allowSave
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.title = @"Details";
        _ticker = ticker;
        _allowSave = allowSave;
        _currentSignal = nil;
        _dataSource = @[];
        _chartSignals = @[];
        _chartView = nil;
        _currentIndex = -1;
    }
    return self;
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.chartRange = [[HGSettings defaultSettings] detailChartRange];

    self.tableView.backgroundColor = [UIColor hg_mainBackgroundColor];
    
    [self updateDataSourceWithSignals:NO reloadTable:NO animated:YES];
    
    if (self.allowSave) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                               target:self
                                                                                               action:@selector(saveAction:)];
    } else {
        self.nextItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow-right"]
                                                         style:UIBarButtonItemStylePlain
                                                        target:self
                                                        action:@selector(nextAction:)];

        self.prevItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow-left"]
                                                         style:UIBarButtonItemStylePlain
                                                        target:self
                                                        action:@selector(prevAction:)];

        [self.navigationItem setRightBarButtonItems:@[ self.nextItem, self.prevItem ] animated:NO];
    }

    [self setupChartContainerView];
}

- (void)viewDidLayoutSubviews
{
    [self.tableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    
    UIEdgeInsets insets = self.tableView.contentInset;
    //insets.top = self.topOrigin;
    
    if (self.chartBottom >= 0) {
        insets.bottom = ContainerHeight;
    }
    
    self.tableView.contentInset = insets;
    self.tableView.scrollIndicatorInsets = insets;
    
    [self.view layoutSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
        
    if (!self.allowSave) {
        self.currentIndex = [[MercuryData sharedData] indexOfTicker:self.ticker];
        [self updatePreviousNext];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (self.hideBlock) {
        self.hideBlock();
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([self isMovingToParentViewController]) {
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:animated];
        self.hud.labelText = @"Loading Data";
        [self.hud removeFromSuperViewOnHide];
        
        if (IsEmpty(self.ticker.position.history)) {
            [[MercuryData sharedData] fetchHistoricalDataForTicker:self.ticker
                                                        completion:^(NSArray *history, NSError *error)
             {
                 if (error) {
                     [self.hud hide:YES];
                     [Flurry logError:kAnalyticsPositionHistoryFetchError message:nil error:error];
                     return;
                 }
                 self.ticker.position.history = history;
                 [self reloadChart];
             }];
        } else {
            [self reloadChart];
        }
    }
}

- (BOOL)shouldAutorotate
{
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
        PositionChartViewController *chartController = [[PositionChartViewController alloc] initWithTicker:self.ticker];
        
        chartController.completionBlock = ^{
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        };
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:chartController];
        navController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [navController setNavigationBarHidden:YES];
        
        [Flurry logAllPageViews:navController];
        [Flurry logEvent:kAnalyticsFullChartLoaded];
        
        [self.navigationController presentViewController:navController animated:YES completion:nil];
    }
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

#pragma mark - Private Methods

- (void)updateDataSourceWithSignals:(BOOL)signals reloadTable:(BOOL)reloadTable animated:(BOOL)animated
{
    NSDictionary *dictionary = @{};
    NSMutableArray *sections =[@[] mutableCopy];
    NSMutableArray *rows = [@[] mutableCopy];
    
    dictionary = @{ @"type" : @"ticker" };
    [rows addObject:dictionary];
    [sections addObject:@{ @"rows" : rows }];

    if (signals) {
        if (IsEmpty(self.currentSignal)) {
            rows = [@[] mutableCopy];
            
            dictionary = @{ @"text" : @"Not Available",
                            @"detail" : @"There's not enough data to generate a signal.",
                            @"text_color" : HexColor(0xedd400),
                            @"type" : @"current_signal" };
            
            [rows addObject:dictionary];
            
            [sections addObject:@{ @"title" : @"Latest Signal", @"rows" : rows }];
        } else {
            NSString *signal = self.currentSignal;
            
            NSString *title = nil;
            NSString *description = nil;
            UIColor *color = [UIColor blackColor];
            
            if ([signal isEqualToString:@"hold"]) {
                title = @"Hold";
                description = @"Looking good! The 50-day SMA is moving above the 200-day SMA.";
                color = HexColor(0x73d216);
            } else if ([signal isEqualToString:@"hold_sideways"]) {
                title = @"Hold (Sideways)";
                description = @"Warning! This position has had a sell signal within the past three months. The 200-day SMA is probably going sideways.";
                color = HexColor(0xedd400);
            } else if ([signal isEqualToString:@"buy"]) {
                title = @"Buy";
                description = @"Great news! We are detecting a buy signal. The 50-day SMA just moved above the 200-day SMA.";
                color = HexColor(0x4e9a06);
            } else if ([signal isEqualToString:@"buy_sideways"]) {
                title = @"Buy (Sideways)";
                description = @"Warning! This position has had a sell signal within the past three months. The 200-day SMA is probably going sideways.";
                color = HexColor(0xedd400);
            } else if ([signal isEqualToString:@"sell"]) {
                title = @"Sell";
                description = @"Warning! We are detecting a sell signal. The 50-day SMA just moved below the 200-day SMA.";
                color = HexColor(0xef2929);
            } else if ([signal isEqualToString:@"avoid"]) {
                title = @"Avoid";
                description = @"Avoid this position! The 50-day SMA is moving below the 200-day SMA.";
                color = HexColor(0xa40000);
            } else if ([signal isEqualToString:@"avoid_downtrend"]) {
                title = @"Avoid (Downtrend)";
                description = @"Avoid this position! The 200-day SMA is in a downtrend.";
                color = HexColor(0xa40000);
            } else {
                title = @"Not Available";
                description = @"There's not enough data to generate a signal.";
                color = HexColor(0xedd400);
            }
            
            if (title && description) {
                rows = [@[] mutableCopy];
                
                dictionary = @{ @"text" : title, @"detail" : description, @"text_color" : color, @"type" : @"current_signal" };
                [rows addObject:dictionary];

                NSMutableDictionary *signalSection = [@{@"title" : @"Latest Signal", @"rows" : rows } mutableCopy ];
                if (self.currentSignalDate) {
                    NSString *dateStr = [[NSDateFormatter hg_signalDateFormatter] stringFromDate:self.currentSignalDate];
                    signalSection[@"footer"] = [NSString stringWithFormat:@"Signal for %@", dateStr];
                }

                [sections addObject:signalSection];
            }
        }
        
        if (!IsEmpty(self.chartSignals)) {
            rows = [@[] mutableCopy];
            
            for (NSDictionary *signal in self.chartSignals) {
                NSString *text = signal[@"signal"];
                NSString *dateStr = [[NSDateFormatter hg_signalDateFormatter] stringFromDate:signal[@"date"]];
                dictionary = @{ @"text" : text,
                                @"detail" : dateStr,
                                @"type" : @"signal" };
                [rows addObject:dictionary];
            }

            NSMutableDictionary *signalSection = [@{ @"title" : @"Recent Signals", @"rows" : rows } mutableCopy];

            if (self.chartSignalStartDate && self.chartSignalEndDate) {
                NSString *startStr = [[NSDateFormatter hg_signalDateFormatter] stringFromDate:self.chartSignalStartDate];
                NSString *endStr = [[NSDateFormatter hg_signalDateFormatter] stringFromDate:self.chartSignalEndDate];

                signalSection[@"footer"] = [NSString stringWithFormat:@"Signals from %@ to %@", startStr, endStr];
            }
            
            [sections addObject:signalSection];
        }
    }
    
    rows = [@[] mutableCopy];
    
    if (!IsEmpty(self.ticker.positionType)) {
        dictionary = @{ @"text" : @"Type",
                        @"detail" : IsEmpty(self.ticker.positionType) ? @"N/A" : self.ticker.positionType,
                        @"type" : @"value1" };
        
        [rows addObject:dictionary];
    }
    
    dictionary = @{ @"text" : @"Exchange",
                    @"detail" : self.ticker.position.stockExchange,
                    @"type" : @"value1" };
    
    [rows addObject:dictionary];
    
    dictionary = @{ @"text" : @"Previous Close",
                    @"detail" : [self.ticker.position formattedPreviousClose],
                    @"type" : @"value1" };
    
    [rows addObject:dictionary];
    
    if ([[self.ticker.positionType uppercaseString] isEqualToString:@"ETF"] ||
        [[self.ticker.positionType uppercaseString] isEqualToString:@"INDEX"] ||
        [[self.ticker.positionType uppercaseString] isEqualToString:@"EQUITY"])
    {
        dictionary = @{ @"text" : @"Today's Open",
                        @"detail" : [self.ticker.position formattedOpen],
                        @"type" : @"value1" };
        
        [rows addObject:dictionary];
        
        dictionary = @{ @"text" : @"Day's Range",
                        @"detail" : [self.ticker.position formattedDayRange],
                        @"type" : @"value1" };
        
        [rows addObject:dictionary];
        
        dictionary = @{ @"text" : @"52 Week Range",
                        @"detail" : [self.ticker.position formattedYearRange],
                        @"type" : @"value1" };
        
        [rows addObject:dictionary];
    }
    
    if ([[self.ticker.positionType uppercaseString] isEqualToString:@"ETF"] ||
        [[self.ticker.positionType uppercaseString] isEqualToString:@"EQUITY"])
    {
        dictionary = @{ @"text" : @"Volume",
                        @"detail" : [self.ticker.position formattedVolume],
                        @"type" : @"value1" };
        
        [rows addObject:dictionary];
        
        dictionary = @{ @"text" : @"Avg. Daily Volume",
                        @"detail" : [self.ticker.position formattedAvgDailyVolume],
                        @"type" : @"value1" };
        
        [rows addObject:dictionary];
    }
    
    [sections addObject:@{ @"title" : @"Additional Information", @"rows" : rows }];
    
    if (!self.allowSave) {
        NSArray *myPositions = [[MercuryData sharedData] arrayForTickerType:HGTickerTypeMyPositions];
        NSArray *myWatchlist = [[MercuryData sharedData] arrayForTickerType:HGTickerTypeMyWatchlist];
        NSArray *myIndexes = [[MercuryData sharedData] arrayForTickerType:HGTickerTypeMyIndexes];

        BOOL myPositionsEnabled = ![myPositions containsObject:self.ticker];
        BOOL myWatchlistEnabled = ![myWatchlist containsObject:self.ticker];
        BOOL myIndexesEnabled = ![myIndexes containsObject:self.ticker];

        if (self.ticker.tickerType == HGTickerTypeMyPositions) {
            rows = [@[] mutableCopy];

            dictionary = @{ @"text" : @"Add to Watchlist",
                            @"target" : HGTickerTypeMyWatchlistKey,
                            @"type" : @"button",
                            @"enabled" : [NSNumber numberWithBool:myWatchlistEnabled] };

            [rows addObject:dictionary];

            dictionary = @{ @"text" : @"Add to Indexes",
                            @"target" : HGTickerTypeMyIndexesKey,
                            @"type" : @"button",
                            @"enabled" : [NSNumber numberWithBool:myIndexesEnabled] };

            [rows addObject:dictionary];

            [sections addObject:@{ @"rows" : rows }];
        } else if (self.ticker.tickerType == HGTickerTypeMyWatchlist) {
            rows = [@[] mutableCopy];

            dictionary = @{ @"text" : @"Add to My Positions",
                            @"target" : HGTickerTypeMyPositionsKey,
                            @"type" : @"button",
                            @"enabled" : [NSNumber numberWithBool:myPositionsEnabled]};

            [rows addObject:dictionary];

            dictionary = @{ @"text" : @"Add to Indexes",
                            @"target" : HGTickerTypeMyIndexesKey,
                            @"type" : @"button",
                            @"enabled" : [NSNumber numberWithBool:myIndexesEnabled]};

            [rows addObject:dictionary];

            [sections addObject:@{ @"rows" : rows }];
        } else if (self.ticker.tickerType == HGTickerTypeMyIndexes) {
            rows = [@[] mutableCopy];

            dictionary = @{ @"text" : @"Add to My Positions",
                            @"target" : HGTickerTypeMyPositionsKey,
                            @"type" : @"button",
                            @"enabled" : [NSNumber numberWithBool:myPositionsEnabled] };

            [rows addObject:dictionary];

            dictionary = @{ @"text" : @"Add to Watchlist",
                            @"target" : HGTickerTypeMyWatchlistKey,
                            @"type" : @"button",
                            @"enabled" : [NSNumber numberWithBool:myWatchlistEnabled] };
            
            [rows addObject:dictionary];
            
            [sections addObject:@{ @"rows" : rows }];
        }
    }
    
    NSRange deleteRange = NSMakeRange(0, [self.dataSource count]);
    
    self.dataSource = sections;
    
    NSRange insertRange = NSMakeRange(0, [self.dataSource count]);
    
    if (reloadTable) {
        if (animated) {
            [self.tableView beginUpdates];
            
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndexesInRange:deleteRange]
                          withRowAnimation:UITableViewRowAnimationFade];
            
            [self.tableView insertSections:[NSIndexSet indexSetWithIndexesInRange:insertRange]
                          withRowAnimation:UITableViewRowAnimationFade];
            
            [self.tableView endUpdates];
        } else {
            [self.tableView reloadData];
        }
    }
}

- (void)reloadChart
{
    if (IsEmpty(self.ticker.position.history)) {
        [self.hud hide:YES];
        return;
    }
    
    [self.ticker.position historyForChartRange:self.chartRange
                                         block:^(NSArray *history, NSArray *SMA1, NSArray *SMA2)
    {
        if ([history count] < 2) {
            [self.hud hide:YES];
            return;
        }
        
        NSTimeInterval minX = [[(HGHistory *)history.lastObject date] timeIntervalSince1970];
        NSTimeInterval maxX = [[(HGHistory *)history.firstObject date] timeIntervalSince1970];
        
        NSMutableArray *chartData = [@[] mutableCopy];
        
        LCLineChartData *closeData = [[LCLineChartData alloc] init];
        closeData.title = self.ticker.symbol;
        closeData.color = [UIColor hg_closeColor];
        closeData.lineWidth = 0.75;
        closeData.xMin = minX;
        closeData.xMax = maxX;
        closeData.itemCount = [history count];

        closeData.getData = ^(NSUInteger item) {
            HGHistory *current = history[item];
            NSDate *date = current.date;
            NSTimeInterval dateInterval = [date timeIntervalSince1970];

            return [LCLineChartDataItem dataItemWithX:dateInterval
                                                    y:[current.close floatValue]
                                               xLabel:[[NSDateFormatter hg_lastTradeDateFormatter] stringFromDate:date]
                                            dataLabel:[NSString stringWithFormat:@"%.02f", [current.close floatValue]]];
        };
        
        [chartData addObject:closeData];
        
        if (!IsEmpty(SMA1)) {
            NSString *title = [NSString stringWithFormat:@"sma(%ld)",
                               (unsigned long)[[HGSettings defaultSettings] SMA1PeriodForChartRange:HGChartRangeOneYearDaily]];
            
            LCLineChartData *SMAData = [[LCLineChartData alloc] init];
            SMAData.title = title;
            SMAData.color = [UIColor hg_SMA1Color];
            SMAData.smoothPlot = YES;
            SMAData.lineWidth = 0.75;
            SMAData.xMin = minX;
            SMAData.xMax = maxX;
            SMAData.itemCount = [SMA1 count];
            
            SMAData.getData = ^(NSUInteger item) {
                HGSMAValue *current = SMA1[item];
                NSDate *date = current.date;
                NSTimeInterval dateInterval = [date timeIntervalSince1970];
                
                return [LCLineChartDataItem dataItemWithX:dateInterval
                                                        y:[current.SMA floatValue]
                                                   xLabel:[[NSDateFormatter hg_lastTradeDateFormatter] stringFromDate:date]
                                                dataLabel:[NSString stringWithFormat:@"%.02f", [current.SMA floatValue]]];
            };
            
            [chartData addObject:SMAData];
        }
        
        if (!IsEmpty(SMA2)) {
            NSString *title = [NSString stringWithFormat:@"sma(%ld)",
                               (unsigned long)[[HGSettings defaultSettings] SMA2PeriodForChartRange:HGChartRangeOneYearDaily]];
            
            LCLineChartData *SMAData = [[LCLineChartData alloc] init];
            SMAData.title = title;
            SMAData.color = [UIColor hg_SMA2Color];
            SMAData.smoothPlot = YES;
            SMAData.lineWidth = 0.75;
            SMAData.xMin = minX;
            SMAData.xMax = maxX;
            SMAData.itemCount = [SMA2 count];
            
            SMAData.getData = ^(NSUInteger item) {
                HGSMAValue *current = SMA2[item];
                NSDate *date = current.date;
                NSTimeInterval dateInterval = [date timeIntervalSince1970];
                
                return [LCLineChartDataItem dataItemWithX:dateInterval
                                                        y:[current.SMA floatValue]
                                                   xLabel:[[NSDateFormatter hg_lastTradeDateFormatter] stringFromDate:date]
                                                dataLabel:[NSString stringWithFormat:@"%.02f", [current.SMA floatValue]]];
            };
            
            [chartData addObject:SMAData];
        }
        
        NSDictionary *yRange = [NSArray hg_minimumAndMaximumRangeForHistory:history
                                                                       SMA1:SMA1
                                                                       SMA2:SMA2];
        
        self.chartView.yMin = [yRange[@"min"] doubleValue];
        self.chartView.yMax = [yRange[@"max"] doubleValue];
        self.chartView.xMin = minX;
        self.chartView.xMax = maxX;
        self.chartView.smoothPlot = NO;
        self.chartView.drawsDataLines = YES;
        self.chartView.drawsDataPoints = NO;
        self.chartView.scaleFont = [UIFont systemFontOfSize:8.0];
        self.chartView.ySteps = [NSArray hg_yStepsForDetailChartIncluding:history SMA1:SMA1 SMA2:SMA2];
        self.chartView.xSteps = [NSArray hg_xStepsInMonthsForHistory:history];
        self.chartView.data = chartData;

        self.currentSignalDate = nil;
        self.chartSignalStartDate = nil;
        self.chartSignalEndDate = nil;
        
        dispatch_queue_t backgroundQueue = dispatch_queue_create(kMercuryDispatchQueue, NULL);
        dispatch_async(backgroundQueue, ^{
            [NSArray SMA_currentSignalForHistory:history SMA1:SMA1 SMA2:SMA2
                                           block:^(BOOL available, NSString *signal, NSArray *pastSignals)
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self.hud hide:YES];
                     
                     if (available) {
                         self.currentSignalDate = [history.firstObject date];
                         self.currentSignal = signal;
                         self.chartSignalStartDate = [history.lastObject date];
                         self.chartSignalEndDate = [history.firstObject date];
                         self.chartSignals = pastSignals;
                     }
                     
                     [self.view layoutIfNeeded];
                     [UIView animateWithDuration:0.3 animations:^{
                         [self updateDataSourceWithSignals:YES reloadTable:YES animated:YES];
                         
                         self.chartContainerView.alpha = 1.0;
                         self.chartBottom = 0.0;
                         
                         self.chartConstraint.constant = self.chartBottom;
                         
                         UIEdgeInsets insets = self.tableView.contentInset;
                         insets.bottom = ContainerHeight;
                         
                         self.tableView.contentInset = insets;
                         self.tableView.scrollIndicatorInsets = insets;
                         [self.view layoutIfNeeded];
                     }];
                 });
             }];
        });
        
    }];
}

- (void)setupChartContainerView
{
    self.chartContainerView = [[UIView alloc] initWithFrame:CGRectZero];
    self.chartContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.chartContainerView.backgroundColor = [UIColor whiteColor];
    self.chartContainerView.alpha = 0.0;
    
    [self.chartContainerView autoSetDimension:ALDimensionHeight toSize:ContainerHeight];
    
    self.chartTopLine = [[UIView alloc] initWithFrame:CGRectZero];
    self.chartTopLine.translatesAutoresizingMaskIntoConstraints = NO;
    self.chartTopLine.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
    
    [self.chartTopLine autoSetDimension:ALDimensionHeight toSize:2.0];
    
    [self.chartContainerView addSubview:self.chartTopLine];
    
    self.chartLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.chartLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.chartLabel.font = [UIFont systemFontOfSize:12.0];
    self.chartLabel.textColor = [UIColor darkGrayColor];
    self.chartLabel.backgroundColor = [UIColor clearColor];
    
    NSString *text = nil;
    if ([self.chartRange isEqualToString:HGChartRangeOneYearDaily]) {
        text = @"ONE YEAR DAILY CHART";
    } else {
        text = @"THREE MONTH DAILY CHART";
    }
    
    self.chartLabel.text = text;
    
    [self.chartLabel autoSetDimension:ALDimensionHeight toSize:ContainerLabelHeight];
    
    [self.chartContainerView addSubview:self.chartLabel];
    
    self.chartLegendLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.chartLegendLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.chartLegendLabel.font = [UIFont systemFontOfSize:10.0];
    self.chartLegendLabel.backgroundColor = [UIColor clearColor];
    self.chartLegendLabel.textAlignment = NSTextAlignmentRight;
    
    NSUInteger sma1Interval = [[HGSettings defaultSettings] SMA1PeriodForChartRange:HGChartRangeOneYearDaily];
    NSUInteger sma2Interval = [[HGSettings defaultSettings] SMA2PeriodForChartRange:HGChartRangeOneYearDaily];
    
    NSString *sma1 = [NSString stringWithFormat:@"sma(%lu)", (unsigned long)sma1Interval];
    NSString *sma2 = [NSString stringWithFormat:@"sma(%lu)", (unsigned long)sma2Interval];
    NSString *legenStr = [NSString stringWithFormat:@"%@  %@", sma1, sma2];
    
    NSRange sma1Range = [legenStr rangeOfString:sma1];
    NSRange sma2Range = [legenStr rangeOfString:sma2];
    
    NSMutableAttributedString *legendAttributedStr = [[NSMutableAttributedString alloc] initWithString:legenStr];
    [legendAttributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor hg_SMA1Color] range:sma1Range];
    [legendAttributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor hg_SMA2Color] range:sma2Range];
    
    self.chartLegendLabel.attributedText = legendAttributedStr;
    
    [self.chartLegendLabel autoSetDimension:ALDimensionHeight toSize:ContainerLabelHeight];
    
    [self.chartContainerView addSubview:self.chartLegendLabel];
    
    self.chartView = [[LCLineChartView alloc] initWithFrame:CGRectZero];
    [self.chartView showLegend:NO animated:NO];
    
    self.chartView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.chartView autoSetDimension:ALDimensionHeight toSize:ContainerChartHeight];
    
    [self.chartContainerView addSubview:self.chartView];
    
    [self.chartTopLine autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0.0];
    [self.chartTopLine autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0.0];
    [self.chartTopLine autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0.0];
    
    [self.chartLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:ContainerChartPaddingTop];
    [self.chartLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10.0];
    
    [self.chartLegendLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:ContainerChartPaddingTop];
    [self.chartLegendLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10.0];
    
    [self.chartLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.chartLegendLabel withOffset:2.0];
    
    [self.chartView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0.0];
    [self.chartView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0.0];
    [self.chartView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0.0];
    
    [self.view addSubview:self.chartContainerView];
    
    self.chartBottom = -(ContainerHeight);
    
    self.chartConstraint = [self.chartContainerView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:self.chartBottom];
    [self.chartContainerView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0.0];
    [self.chartContainerView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0.0];
}

- (void)updatePreviousNext
{
    NSInteger total = [[[MercuryData sharedData] arrayForTickerType:self.ticker.tickerType] count];
    if (self.currentIndex < 0) {
        self.prevItem.enabled = NO;
        self.nextItem.enabled = NO;
        return;
    } else if (self.currentIndex == 0) {
        self.prevItem.enabled = NO;
        self.nextItem.enabled = YES;
    } else if (self.currentIndex == total - 1) {
        self.prevItem.enabled = YES;
        self.nextItem.enabled = NO;
    } else {
        self.prevItem.enabled = YES;
        self.nextItem.enabled = YES;
    }
}

- (void)updateViewControllers
{
    NSArray *array = [[MercuryData sharedData] arrayForTickerType:self.ticker.tickerType];
    DLog(@"Update Controllers: %@", array);

    HGTicker *ticker = array[self.currentIndex];

    NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
    [viewControllers removeLastObject];

    PositionDetailViewController *detailController = [[PositionDetailViewController alloc] initWithTicker:ticker];
    detailController.hidesBottomBarWhenPushed = YES;

    [viewControllers addObject:detailController];

    [self.navigationController setViewControllers:viewControllers animated:YES];
}

#pragma mark - Selector Methods

- (void)saveAction:(id)sender
{
    if (IsEmpty(self.ticker.positionType) ||
        [[self.ticker.positionType uppercaseString] isEqualToString:@"FUND"] ||
        [[self.ticker.positionType uppercaseString] isEqualToString:@"ETF"] ||
        [[self.ticker.positionType uppercaseString] isEqualToString:@"INDEX"])
    {
        if (self.saveBlock) {
            self.saveBlock(self.ticker);
        }
    } else {
        NSString *message = [NSString stringWithFormat:@"You are about to save a position of type \"%@\" "
                             "but our signals are only recommended for Mutual Funds, ETFs and Indexes. "
                             "Are you sure you want to do this?", self.ticker.positionType];

        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Save", nil];
        [alertView show];
    }
}

- (void)nextAction:(id)sender
{
    if (self.currentIndex < 0) {
        return;
    }

    NSArray *array = [[MercuryData sharedData] arrayForTickerType:self.ticker.tickerType];

    if (self.currentIndex >= [array count] - 1) {
        return;
    }

    [Flurry logEvent:kAnalyticsPositionDetailNextPage
      withParameters:@{ kAnalyticsParameterKeyType : [MercuryData keyForTickerType:self.ticker.tickerType] }];

    self.currentIndex++;
    [self updateViewControllers];
}

- (void)prevAction:(id)sender
{
    if (self.currentIndex < 0) {
        return;
    }

    if (self.currentIndex == 0) {
        return;
    }

    [Flurry logEvent:kAnalyticsPositionDetailPrevPage
      withParameters:@{ kAnalyticsParameterKeyType : [MercuryData keyForTickerType:self.ticker.tickerType] }];

    self.currentIndex--;
    [self updateViewControllers];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataSource count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource[section][@"rows"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *SummaryIdentifier = @"SummaryCell";
    static NSString *CurrentSignalIdentifier = @"CurrentSignalCell";
    static NSString *SignalIdentifier = @"SignalCell";
    static NSString *ButtonIdentifier = @"ButtonCell";
    static NSString *Value1Identifier = @"Value1Cell";
    
    NSDictionary *dictionary = self.dataSource[indexPath.section][@"rows"][indexPath.row];
    NSString *rowType = dictionary[@"type"];

    if ([rowType isEqualToString:@"button"]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ButtonIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ButtonIdentifier];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
        }

        BOOL enabled = [dictionary[@"enabled"] boolValue];

        cell.textLabel.text = dictionary[@"text"];
        cell.textLabel.textColor = enabled ? [UIColor hg_highlightColor] : [UIColor lightGrayColor];
        cell.selectionStyle = enabled ? UITableViewCellSelectionStyleDefault : UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;

        return cell;
    }
    
    if ([rowType isEqualToString:@"value1"]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Value1Identifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:Value1Identifier];
            cell.textLabel.font = [UIFont systemFontOfSize:14.0];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:14.0];
        }
        
        cell.textLabel.text = dictionary[@"text"];
        cell.detailTextLabel.text = dictionary[@"detail"];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        return cell;
    }

    if ([rowType isEqualToString:@"ticker"]) {
        PositionSummaryCell *cell = [tableView dequeueReusableCellWithIdentifier:SummaryIdentifier];
        if (cell == nil) {
            cell = [[PositionSummaryCell alloc] initWithReuseIdentifier:SummaryIdentifier];
        }

        cell.symbolLabel.text = self.ticker.position.symbol;
        cell.nameLabel.text = self.ticker.position.name;
        cell.closeLabel.text = self.ticker.position.close;
        cell.changeLabel.text = [self.ticker.position priceAndPercentageChange];
        cell.dateLabel.text = self.ticker.position.lastTradeDateString;
        
        cell.changeLabel.textColor = [self.ticker.position colorForChangeType];
        
        return cell;
    }
    
    if ([rowType isEqualToString:@"current_signal"]) {
        SignalStatusCell *cell = [tableView dequeueReusableCellWithIdentifier:CurrentSignalIdentifier];
        if (cell == nil) {
            cell = [[SignalStatusCell alloc] initWithReuseIdentifier:CurrentSignalIdentifier];
        }
        
        cell.titleLabel.text = dictionary[@"text"];
        cell.titleLabel.textColor = dictionary[@"text_color"];
        cell.descriptionLabel.text = dictionary[@"detail"];
        
        return cell;
    }

    if ([rowType isEqualToString:@"signal"]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SignalIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SignalIdentifier];
            cell.textLabel.font = [UIFont systemFontOfSize:15.0];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:15.0];
        }

        UIColor *textColor = [UIColor blackColor];
        if ([dictionary[@"text"] isEqualToString:@"buy"]) {
            textColor = [UIColor hg_changePositiveColor];
        } else if ([dictionary[@"text"] isEqualToString:@"sell"]) {
            textColor = [UIColor hg_changeNegativeColor];
        }

        cell.textLabel.text = [dictionary[@"text"] capitalizedString];
        cell.textLabel.textColor = textColor;
        cell.detailTextLabel.text = dictionary[@"detail"];

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;

        return cell;
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSDictionary *dictionary = self.dataSource[indexPath.section][@"rows"][indexPath.row];
    NSString *rowType = dictionary[@"type"];
    NSString *target = dictionary[@"target"];
    BOOL enabled = [dictionary[@"enabled"] boolValue];

    if ([rowType isEqualToString:@"button"] && enabled) {
        HGTickerType tickerType = [MercuryData typeForTickerKey:target];

        HGTicker *ticker = [HGTicker tickerWithType:tickerType symbol:self.ticker.symbol];
        ticker.position = self.ticker.position;

        [[MercuryData sharedData] addTicker:ticker
                                 tickerType:tickerType
                                 completion:^(BOOL succeded, NSError *error)
        {
            if (error && error.code == kMercuryErrorCodeMaximumPositions) {
                NSString *message = [NSString stringWithFormat:@"You have reached the maximum limit of positions in %@. "
                                     "Please remove other positions to continue.", [MercuryData titleForTickerType:ticker.tickerType]];
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[MercuryData titleForTickerType:ticker.tickerType]
                                                                    message:message
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                [alertView show];
            }
            
            if (!succeded) {
                return;
            }
            
            [self updateDataSourceWithSignals:YES reloadTable:YES animated:NO];
            
            NSDictionary *userInfo = @{ @"ticker" : ticker,
                                        @"ticker_key" : target };
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PositionSavedNotification
                                                                object:nil
                                                              userInfo:userInfo];
            
            NSString *message = [NSString stringWithFormat:@"Position %@ was saved to %@.",
                                 ticker.symbol,
                                 [MercuryData titleForTickerType:tickerType]];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Position Saved"
                                                                message:message
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44.0;
    
    NSDictionary *dictionary = self.dataSource[indexPath.section][@"rows"][indexPath.row];
    NSString *rowType = dictionary[@"type"];
    
    if ([rowType isEqualToString:@"current_signal"]) {
        height = 94.0;
    } else if ([rowType isEqualToString:@"ticker"]) {
        height = 126.0;
    }

    return height;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    NSDictionary *dictionary = self.dataSource[section];
    title = dictionary[@"title"];
    return title;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSString *title = nil;
    NSDictionary *dictionary = self.dataSource[section];
    title = dictionary[@"footer"];
    return title;
}

#pragma mark - UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        if (self.saveBlock) {
            self.saveBlock(self.ticker);
        }
    }
}

@end

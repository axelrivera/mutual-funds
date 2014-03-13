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

@interface PositionDetailViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UIBarButtonItem *addToMyPositionsButton;
@property (strong, nonatomic) UIBarButtonItem *removeFromMyPositionsButton;
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
        _dataSource = @[];
        _chartSignals = @[];
        _chartView = nil;
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
        if (self.ticker.tickerType == HGTickerTypeMyWatchlist) {
            self.addToMyPositionsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"star"]
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(addToMyPositionsAction:)];
            
            self.removeFromMyPositionsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"star-selected"]
                                                                                style:UIBarButtonItemStylePlain
                                                                               target:self
                                                                               action:@selector(removeFromMyPositionsAction:)];
        }
    }
    
    self.chartBottom = -(ContainerHeight);

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
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([self isMovingToParentViewController]) {
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:animated];
        self.hud.labelText = @"Fetching Data";
        [self.hud removeFromSuperViewOnHide];
        
        [[MercuryData sharedData] fetchHistoricalDataForTicker:self.ticker
                                                    completion:^(NSArray *history, NSError *error)
         {
             if (error) {
                 [Flurry logError:kAnalyticsPositionHistoryFetchError message:nil error:error];
                 return;
             }
             self.ticker.position.history = history;
             [self reloadChart];
         }];
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
        if (!IsEmpty(self.currentSignal)) {
            NSString *signal = self.currentSignal;
            
            NSString *title = nil;
            NSString *description = nil;
            UIColor *color = [UIColor blackColor];
            
            if ([signal isEqualToString:@"hold"]) {
                title = @"Hold";
                description = @"Looking good! The 50 day SMA is moving above the 200 day SMA.";
                color = HexColor(0x73d216);
            } else if ([signal isEqualToString:@"hold_sideways"]) {
                title = @"Hold (Sideways)";
                description = @"Warning! This position has had a sell signal within the past three months. The 200 day SMA is probably going sideways.";
                color = HexColor(0xedd400);
            } else if ([signal isEqualToString:@"buy"]) {
                title = @"Buy";
                description = @"Great news! We are detecting a buy signal. The 50 day SMA just moved above the 200 day SMA.";
                color = HexColor(0x4e9a06);
            } else if ([signal isEqualToString:@"buy_sideways"]) {
                title = @"Buy (Sideways)";
                description = @"Warning! This position has had a sell signal within the past three months. The 200 day SMA is probably going sideways.";
                color = HexColor(0xedd400);
            } else if ([signal isEqualToString:@"sell"]) {
                title = @"Sell";
                description = @"Warning! We are detecting a sell signal. The 50 day SMA just moved below the 200 day SMA.";
                color = HexColor(0xef2929);
            } else if ([signal isEqualToString:@"avoid"]) {
                title = @"Avoid";
                description = @"Avoid this position! The 50 day SMA is moving below the 200 day SMA.";
                color = HexColor(0xa40000);
            } else {
                title = @"Not Enouth Data";
                description = @"There's not enough data to generate a signal.";
                color = HexColor(0xedd400);
            }
            
            if (title && description) {
                rows = [@[] mutableCopy];
                
                dictionary = @{ @"text" : title, @"detail" : description, @"text_color" : color, @"type" : @"current_signal" };
                [rows addObject:dictionary];
                
                [sections addObject:@{ @"title" : @"Latest Signal", @"rows" : rows }];
            }
        }
        
        rows = [@[] mutableCopy];

        for (NSDictionary *signal in self.chartSignals) {
            NSString *text = signal[@"signal"];
            NSString *dateStr = [[NSDateFormatter hg_signalDateFormatter] stringFromDate:signal[@"date"]];
            dictionary = @{ @"text" : text,
                            @"detail" : dateStr,
                            @"type" : @"signal" };
            [rows addObject:dictionary];
        }
        
        if (!IsEmpty(rows)) {
            [sections addObject:@{ @"title" : @"Recent Signals", @"rows" : rows }];
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
        return;
    }
    
    [self.ticker.position historyForChartRange:self.chartRange
                                         block:^(NSArray *history, NSArray *SMA1, NSArray *SMA2)
    {
        if ([history count] < 2) {
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
        
        self.hud.labelText = @"Loading Signals";
        
        dispatch_queue_t backgroundQueue = dispatch_queue_create(kMercuryDispatchQueue, NULL);
        dispatch_async(backgroundQueue, ^{
            [NSArray SMA_currentSignalForHistory:history SMA1:SMA1 SMA2:SMA2
                                           block:^(BOOL available, NSString *signal, NSArray *pastSignals)
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self.hud hide:YES];
                     
                     if (available) {
                         self.currentSignal = signal;
                         self.chartSignals = pastSignals;
                         [self updateDataSourceWithSignals:YES reloadTable:YES animated:YES];
                         
                         [self.view layoutIfNeeded];
                         [UIView animateWithDuration:0.3 animations:^{
                             self.chartBottom = 0.0;
                             
                             self.chartConstraint.constant = self.chartBottom;
                             
                             UIEdgeInsets insets = self.tableView.contentInset;
                             insets.bottom = ContainerHeight;
                             
                             self.tableView.contentInset = insets;
                             self.tableView.scrollIndicatorInsets = insets;
                             [self.view layoutIfNeeded];
                         }];
                     }
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
    
    self.chartConstraint = [self.chartContainerView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:self.chartBottom];
    [self.chartContainerView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0.0];
    [self.chartContainerView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0.0];
}

#pragma mark - Selector Methods

- (void)saveAction:(id)sender
{
    if (self.saveBlock) {
        self.saveBlock(self.ticker);
    }
}

- (void)addToMyPositionsAction:(id)sender
{
    HGTicker *ticker = [HGTicker tickerWithType:HGTickerTypeMyPositions symbol:self.ticker.symbol];
    ticker.position = self.ticker.position;
    
    [[MercuryData sharedData].myPositions addObject:ticker];

    [[NSNotificationCenter defaultCenter] postNotificationName:MyPositionsReloadedNotification
                                                        object:nil
                                                      userInfo:nil];

    [self.navigationItem setRightBarButtonItem:self.removeFromMyPositionsButton animated:YES];

    NSString *message = [NSString stringWithFormat:@"%@ was added to your positions.", self.ticker.symbol];

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Mercury"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)removeFromMyPositionsAction:(id)sender
{
    [[MercuryData sharedData] removePositionWithSymbol:self.ticker.symbol];
    [self.navigationItem setRightBarButtonItem:self.addToMyPositionsButton animated:YES];
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
    
    NSDictionary *dictionary = self.dataSource[indexPath.section][@"rows"][indexPath.row];
    NSString *rowType = dictionary[@"type"];

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

@end

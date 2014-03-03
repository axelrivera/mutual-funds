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
#import <NCIChartView.h>

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
        _chartDataSource = @[];
        _chartLimitedDataSource = @[];
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
    
    self.currentChartPeriod = [[HGSettings defaultSettings] detailChartPeriod];

    self.tableView.backgroundColor = [UIColor hg_mainBackgroundColor];
    
    [self updateDataSourceWithSignals:NO reloadTable:NO animated:YES];
    
    [[MercuryData sharedData] fetchHistoricalDataForTicker:self.ticker
                                                completion:^(NSArray *history, NSError *error)
    {
        self.ticker.position.history = history;
        [self reloadChart];
    }];
    
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

    [self setupChartContainerView];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self.tableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    
    UIEdgeInsets insets = self.tableView.contentInset;
    insets.top = self.topOrigin;
    insets.bottom = ContainerHeight;
    
    self.tableView.contentInset = insets;
    self.tableView.scrollIndicatorInsets = insets;
    
    [self.chartContainerView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0.0];
    [self.chartContainerView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0.0];
    [self.chartContainerView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0.0];
    
    [self.view layoutSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotate
{
    if (IsEmpty(self.chartDataSource)) {
        return NO;
    }
    
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
        PositionChartViewController *chartController = [[PositionChartViewController alloc] initWithTicker:self.ticker
                                                                                                chartArray:self.chartDataSource];
        
        chartController.completionBlock = ^{
            [self.tabBarController dismissViewControllerAnimated:YES completion:nil];
        };
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:chartController];
        navController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [navController setNavigationBarHidden:YES];
        
        [self.tabBarController presentViewController:navController animated:YES completion:nil];
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
            NSString *signal = self.currentSignal[@"signal"];
            
            NSString *title = nil;
            NSString *description = nil;
            UIColor *color = [UIColor blackColor];
            
            if ([signal isEqualToString:@"hold"]) {
                title = @"Hold";
                description = @"Looking good! The 50 day SMA is moving above the 200 day SMA.";
                color = HexColor(0x73d216);
            } else if ([signal isEqualToString:@"hold_sideways"]) {
                title = @"Hold (Sideways)";
                description = @"Warning! This position has had multiple signals within the past three months. The 200 day SMA is probably going sideways.";
                color = HexColor(0xedd400);
            } else if ([signal isEqualToString:@"buy"]) {
                title = @"Buy";
                description = @"Great news! We are detecting a buy signal. The 50 day SMA just moved above the 200 day SMA.";
                color = HexColor(0x4e9a06);
            } else if ([signal isEqualToString:@"buy_sideways"]) {
                title = @"Buy (Sideways)";
                description = @"Warning! This position has had multiple signals within the past three months. The 200 day SMA is probably going sideways.";
                color = HexColor(0xedd400);
            } else if ([signal isEqualToString:@"sell"]) {
                title = @"Sell";
                description = @"Warning! We are detecting a sell signal. The 50 day SMA just moved below the 200 day SMA.";
                color = HexColor(0xef2929);
            } else if ([signal isEqualToString:@"avoid"]) {
                title = @"Avoid";
                description = @"Avoid this position! The 50 day SMA is moving below the 200 day SMA.";
                color = HexColor(0xa40000);
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
    
//    NSString* (^xRenderBlock)(double) = ^(double value) {
//        DLog(@"Value: %f", value);
//        return [NSString stringWithFormat:@"%.0f", value];
//    };
    
    NSString *currentPeriod = [[HGSettings defaultSettings] detailChartPeriod];
    
    NSUInteger interval = [[HGSettings defaultSettings] intervalForChartPeriod:currentPeriod];
    NSUInteger sma1 = [[HGSettings defaultSettings] SMA1forChartPeriod:currentPeriod];
    NSUInteger sma2 = [[HGSettings defaultSettings] SMA2forChartPeriod:currentPeriod];
    
    [self.ticker.position  calculateChartWithSMA1:sma1 SMA2:sma2 completion:^(NSArray *chartArray) {
        self.chartDataSource = chartArray;
        
        NSDate *startDate = [NSDate chartStartDateForInterval:interval];
        
        self.chartLimitedDataSource = [chartArray chartDailyArrayWithStartDate:startDate];
        self.chartSignals = [self.chartLimitedDataSource SMA_arrayOfAnalizedSignals];
        self.currentSignal = [self.chartLimitedDataSource SMA_currentSignal];

        [self updateDataSourceWithSignals:YES reloadTable:YES animated:YES];
        
        if (!IsEmpty(self.chartView.chartData)) {
            [self.chartView.chartData removeAllObjects];
        }
        
        for (NSInteger i = 0; i < [self.chartLimitedDataSource count]; i++) {
            NSDictionary *dictionary = self.chartLimitedDataSource[i];
            
            NSDate *date = dictionary[@"date"];
            NSTimeInterval dateInterval = [date timeIntervalSince1970];
            
            [self.chartView addPoint:dateInterval val:@[ dictionary[@"close"], dictionary[@"sma1"], dictionary[@"sma2"] ]];
        }
        
        [self.chartView drawChart];
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
    self.chartTopLine.backgroundColor = [UIColor hg_tableSeparatorColor];
    
    [self.chartTopLine autoSetDimension:ALDimensionHeight toSize:1.0];
    
    [self.chartContainerView addSubview:self.chartTopLine];
    
    self.chartLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.chartLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.chartLabel.font = [UIFont systemFontOfSize:12.0];
    self.chartLabel.textColor = [UIColor darkGrayColor];
    self.chartLabel.backgroundColor = [UIColor clearColor];
    
    NSString *text = nil;
    if ([self.currentChartPeriod isEqualToString:HGChartPeriodOneYearDaily]) {
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
    
    NSUInteger sma1Interval = [[HGSettings defaultSettings] SMA1forChartPeriod:self.currentChartPeriod];
    NSUInteger sma2Interval = [[HGSettings defaultSettings] SMA2forChartPeriod:self.currentChartPeriod];
    
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

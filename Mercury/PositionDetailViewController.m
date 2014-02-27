//
//  PositionDetailViewController.m
//  Mercury
//
//  Created by Axel Rivera on 2/22/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "PositionDetailViewController.h"

#import "PositionChartViewController.h"
#import "PositionSummaryCell.h"
#import <NCIChartView.h>

@interface PositionDetailViewController ()

@property (strong, nonatomic) UIBarButtonItem *addToMyPositionsButton;
@property (strong, nonatomic) UIBarButtonItem *removeFromMyPositionsButton;

- (void)updateDataSourceIncludeChart:(BOOL)includeChart;
- (void)reloadChart;

@end

@implementation PositionDetailViewController

- (instancetype)initWithTicker:(HGTicker *)ticker
{
    return [self initWithTicker:ticker allowSave:NO];
}

- (instancetype)initWithTicker:(HGTicker *)ticker allowSave:(BOOL)allowSave
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"Details";
        _ticker = ticker;
        _allowSave = allowSave;
        _dataSource = @[];
        _chartView = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.backgroundColor = [UIColor hg_mainBackgroundColor];
    
    [self updateDataSourceIncludeChart:NO];
    
    [[MercuryData sharedData] fetchHistoricalDataForSymbol:self.ticker.symbol
                                                completion:^(NSArray *history, NSError *error)
    {
        self.ticker.position.history = history;
        [self reloadChart];
    }];

    if (self.ticker.tickerType == HGTickerTypeWatchlist) {
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (self.ticker.tickerType == HGTickerTypeWatchlist) {
        BOOL present = [[MercuryData sharedData] isSymbolPresentInMyPositions:self.ticker.symbol];
        if (present) {
            self.navigationItem.rightBarButtonItem = self.removeFromMyPositionsButton;
        } else {
            self.navigationItem.rightBarButtonItem = self.addToMyPositionsButton;
        }
    }
}

- (BOOL)shouldAutorotate
{
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
        PositionChartViewController *chartController = [[PositionChartViewController alloc] initWithTicker:self.ticker];
        chartController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self.navigationController presentViewController:chartController animated:YES completion:nil];
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

- (void)updateDataSourceIncludeChart:(BOOL)includeChart
{
    NSDictionary *dictionary = @{};
    NSMutableArray *sections =[@[] mutableCopy];
    NSMutableArray *rows = [@[] mutableCopy];
    
    if (self.allowSave) {
        NSString *text = self.ticker.tickerType == HGTickerTypeWatchlist ? @"Save to Watchlist" : @"Save to My Positions";
        dictionary = @{ @"text": text, @"type" : @"save" };
        [rows addObject:dictionary];
        
        [sections addObject:@{ @"rows" : rows }];
    }
    
    rows = [@[] mutableCopy];
    
    dictionary = @{ @"type" : @"ticker" };
    [rows addObject:dictionary];
    [sections addObject:@{ @"rows" : rows }];
    
    rows = [@[] mutableCopy];
    
    dictionary = @{ @"type" : @"chart", @"include" : [NSNumber numberWithBool:includeChart] };
    [rows addObject:dictionary];
    [sections addObject:@{ @"title" : @"Three Month Chart", @"rows" : rows }];
    
    self.dataSource = sections;
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
    
    self.chartView = [[NCISimpleChartView alloc]
                      initWithFrame:CGRectZero
                      andOptions: @{nciIsFill: @(NO),
                                    nciLineColors: @[HexColor(0x204A87), HexColor(0x5C3566), HexColor(0xCE5C00)],
                                    nciLineWidths: @[@1, [NSNull null]],
                                    nciUseDateFormatter: @(YES),
                                    nciHasSelection: @(NO)}];
    
    [self.ticker.position  calculateChartForInterval:90 SMA1:50 SMA2:200 completion:^(NSArray *chartArray) {
        self.chartDataSource = chartArray;
        for (NSInteger i = 0; i < [self.chartDataSource count]; i++) {
            NSDictionary *dictionary = self.chartDataSource[i];
            
            NSDate *date = dictionary[@"date"];
            NSTimeInterval dateInterval = [date timeIntervalSince1970];
            
            [self.chartView addPoint:dateInterval val:@[ dictionary[@"close"], dictionary[@"sma1"], dictionary[@"sma2"] ]];
        }
        
        [self.chartView drawChart];
        
        [self updateDataSourceIncludeChart:YES];
        [self.tableView reloadData];
    }];
}

#pragma mark - Selector Methods

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
    static NSString *SaveIdentifier = @"SaveCell";
    
    NSDictionary *dictionary = self.dataSource[indexPath.section][@"rows"][indexPath.row];
    NSString *rowType = dictionary[@"type"];

    if ([rowType isEqualToString:@"save"]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SaveIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SaveIdentifier];
            NSString *textStr = self.ticker.tickerType == HGTickerTypeWatchlist ? @"Save to Watchlist" : @"Save to My Positions";
            cell.textLabel.text = textStr;
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.textColor = [UIColor hg_highlightColor];
        }

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
        cell.dateLabel.text = self.ticker.position.lastTradeDate;
        
        cell.changeLabel.textColor = [self.ticker.position colorForChangeType];
        
        return cell;
    }
    
    BOOL includeChart = [dictionary[@"include"] boolValue];
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    CGRect viewRect = CGRectMake(0.0, 0.0, tableView.frame.size.width, 200.0);
    
    if (includeChart) {
        self.chartView.frame = viewRect;
        cell.accessoryView = self.chartView;
        [self.chartView setNeedsDisplay];
    } else {
        UIView *view = [[UIView alloc] initWithFrame:viewRect];
        view.backgroundColor = [UIColor clearColor];
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        CGRect indicatorRect = indicatorView.frame;
        [indicatorView startAnimating];
        
        indicatorRect.origin.x = (view.frame.size.width - indicatorRect.size.width) / 2.0;
        indicatorRect.origin.y = (view.frame.size.height - indicatorRect.size.height) / 2.0;
        
        indicatorView.frame = indicatorRect;
        
        [view addSubview:indicatorView];
        cell.accessoryView = view;
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (self.allowSave && indexPath.row == 0) {
        if (self.saveBlock) {
            self.allowSave = NO;
            self.saveBlock(self.ticker);
            
            [self updateDataSourceIncludeChart:YES];
            
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44.0;
    
    NSDictionary *dictionary = self.dataSource[indexPath.section][@"rows"][indexPath.row];
    NSString *rowType = dictionary[@"type"];
    
    if ([rowType isEqualToString:@"save"]) {
        height = 44.0;
    } else if ([rowType isEqualToString:@"ticker"]) {
        height = 126.0;
    } else if ([rowType isEqualToString:@"chart"]) {
        height = 200.0;
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

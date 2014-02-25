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
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.backgroundColor = [UIColor hg_mainBackgroundColor];

    self.chartView = [[NCISimpleChartView alloc]
                      initWithFrame:CGRectZero
                      andOptions: @{nciIsFill: @(NO),
                                    nciSelPointSizes: @[@5, @10, @5]}];

    [[MercuryData sharedData] fetchHistoricalDataForSymbol:self.ticker.symbol
                                                completion:^(NSArray *historicalData, NSError *error)
    {
        self.ticker.position.historyArray = historicalData;
        self.chartDataSource = [[historicalData subarrayWithRange:NSMakeRange(0, 90)] reversedArray];
        
        for (NSInteger i = 0; i < [self.chartDataSource count]; i++) {
            HGHistory * history = self.chartDataSource[i];
            [self.chartView addPoint:(double)i val:@[ history.close ]];
        }

        [self.chartView drawChart];
        
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
    NSInteger sections = 2;
    if (self.allowSave) {
        sections = 3;
    }

    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ChartIdentifier = @"ChartCell";
    static NSString *SummaryIdentifier = @"SummaryCell";
    static NSString *SaveIdentifier = @"SaveCell";

    if (self.allowSave && indexPath.section == 0) {
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

    if ((self.allowSave && indexPath.section == 1) || indexPath.section == 0) {
        PositionSummaryCell *cell = [tableView dequeueReusableCellWithIdentifier:SummaryIdentifier];
        if (cell == nil) {
            cell = [[PositionSummaryCell alloc] initWithReuseIdentifier:SummaryIdentifier];
        }

        cell.symbolLabel.text = self.ticker.position.symbol;
        cell.nameLabel.text = self.ticker.position.name;
        cell.closeLabel.text = self.ticker.position.close;
        cell.changeLabel.text = [self.ticker.position priceAndPercentageChange];
        cell.dateLabel.text = self.ticker.position.lastTradeDate;
        
        return cell;
    }

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ChartIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ChartIdentifier];
        self.chartView.frame = CGRectMake(0.0, 0.0, tableView.frame.size.width, 200.0);
        cell.accessoryView = self.chartView;
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

            [self.tableView reloadData];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.0;

    if (self.allowSave) {
        if (indexPath.section == 0) {
            height = 44;
        } else if (indexPath.section == 1) {
            height = 146.0;
        } else {
            height = 200.0;
        }
    } else {
        if (indexPath.section == 0) {
            height = 146.0;
        } else if (indexPath.section == 1) {
            return 200.0;
        }
    }

    return height;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    if (self.allowSave) {
        if (section == 2) {
            title = @"Three Month Chart";
        }
    } else {
        if (section == 1) {
            title = @"Three Month Chart";
        }
    }
    return title;
}

@end

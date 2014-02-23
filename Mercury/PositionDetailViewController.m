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

@end

@implementation PositionDetailViewController

- (instancetype)initWithPosition:(HGPosition *)position
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"Details";
        _position = position;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.chartView = [[NCISimpleChartView alloc]
                      initWithFrame:CGRectZero
                      andOptions: @{nciIsFill: @(NO),
                                    nciSelPointSizes: @[@5, @10, @5]}];

    [[MercuryData sharedData] fetchHistoricalDataForSymbol:self.position.symbol
                                                completion:^(NSArray *historicalData, NSError *error)
    {
        self.position.historyArray = historicalData;
        self.chartDataSource = [[historicalData subarrayWithRange:NSMakeRange(0, 90)] reversedArray];

        for (NSInteger i = 0; i < [self.chartDataSource count]; i++) {
            HGHistory *history = self.chartDataSource[i];
            [self.chartView addPoint:(double)i val:@[ history.close ]];
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
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
        PositionChartViewController *chartController = [[PositionChartViewController alloc] initWithPosition:self.position];
        chartController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self.navigationController presentViewController:chartController animated:YES completion:nil];
    }
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ChartIdentifier = @"ChartCell";
    static NSString *SummaryIdentifier = @"SummaryCell";

    if (indexPath.section == 0) {
        PositionSummaryCell *cell = [tableView dequeueReusableCellWithIdentifier:SummaryIdentifier];
        if (cell == nil) {
            cell = [[PositionSummaryCell alloc] initWithReuseIdentifier:SummaryIdentifier];
        }

        cell.symbolLabel.text = self.position.symbol;
        cell.nameLabel.text = self.position.name;
        cell.closeLabel.text = self.position.close;
        cell.changeLabel.text = [self.position priceAndPercentageChange];
        cell.dateLabel.text = self.position.lastTradeDate;
        
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 146.0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    if (section == 1) {
        title = @"Chart";
    }
    return title;
}

@end

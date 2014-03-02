//
//  SettingsViewController.m
//  Mercury
//
//  Created by Axel Rivera on 2/22/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"Settings";

        self.tabBarItem.image = [UIImage imageNamed:@"gear"];
        self.tabBarItem.selectedImage = [UIImage imageNamed:@"gear-selected"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.backgroundColor = [UIColor hg_mainBackgroundColor];
    self.currentDetailChartPeriod = [[HGSettings defaultSettings] detailChartPeriod];
    
    self.detailChartSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[ @"3 Months", @"1 Year" ]];
    [self.detailChartSegmentedControl setWidth:80.0 forSegmentAtIndex:0];
    [self.detailChartSegmentedControl setWidth:80.0 forSegmentAtIndex:1];
    
    [self.detailChartSegmentedControl addTarget:self
                                         action:@selector(detailSegmentedControlChanged:)
                               forControlEvents:UIControlEventValueChanged];
    
    [self updateDataSource];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([[[HGSettings defaultSettings] detailChartPeriod] isEqualToString:HGChartPeriodThreeMonthDaily]) {
        self.detailChartSegmentedControl.selectedSegmentIndex = 0;
    } else {
        self.detailChartSegmentedControl.selectedSegmentIndex = 1;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods

- (void)updateDataSource
{
    NSDictionary *dictionary = @{};
    NSMutableArray *sections = [@[] mutableCopy];
    NSMutableArray *rows = [@[] mutableCopy];
    
    dictionary = @{ @"text" : @"Default Period",
                    @"key" : @"detail_chart" };
    
    [rows addObject:dictionary];
    
    [sections addObject:@{ @"title" : @"Position Detail", @"rows" : rows }];
    
    self.dataSource = sections;
}

#pragma mark - Selector Methods

- (void)detailSegmentedControlChanged:(UISegmentedControl *)segmentedControl
{
    NSString *chartPeriod = nil;
    if (segmentedControl.selectedSegmentIndex == 0) {
        chartPeriod = HGChartPeriodThreeMonthDaily;
    } else {
        chartPeriod = HGChartPeriodOneYearDaily;
    }
    
    [[HGSettings defaultSettings] setDetailChartPeriod:chartPeriod];
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
    static NSString *ChartDetaiIdentifier = @"ChartDetailCell";
    
    NSDictionary *dictionary = self.dataSource[indexPath.section][@"rows"][indexPath.row];
    NSString *key = dictionary[@"key"];
    
    if ([key isEqualToString:@"detail_chart"]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ChartDetaiIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ChartDetaiIdentifier];
            cell.textLabel.font = [UIFont systemFontOfSize:14.0];
            cell.accessoryView = self.detailChartSegmentedControl;
        }
        
        cell.textLabel.text = dictionary[@"text"];
        
        return cell;
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDictionary *dictionary = self.dataSource[section];
    return dictionary[@"title"];
}

@end

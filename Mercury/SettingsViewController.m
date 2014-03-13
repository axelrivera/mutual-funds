//
//  SettingsViewController.m
//  Mercury
//
//  Created by Axel Rivera on 2/22/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "SettingsViewController.h"

#import "IntroViewController.h"

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
    
    self.detailChartSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[ @"3M", @"1Y" ]];
    [self.detailChartSegmentedControl setWidth:50.0 forSegmentAtIndex:0];
    [self.detailChartSegmentedControl setWidth:50.0 forSegmentAtIndex:1];
    
    [self.detailChartSegmentedControl addTarget:self
                                         action:@selector(detailSegmentedControlChanged:)
                               forControlEvents:UIControlEventValueChanged];
    
    self.fullscreenChartSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[ @"3M", @"1Y", @"10Y" ]];
    [self.fullscreenChartSegmentedControl setWidth:50.0 forSegmentAtIndex:0];
    [self.fullscreenChartSegmentedControl setWidth:50.0 forSegmentAtIndex:1];
    [self.fullscreenChartSegmentedControl setWidth:50.0 forSegmentAtIndex:2];
    
    [self.fullscreenChartSegmentedControl addTarget:self
                                             action:@selector(fullscreenChartSegmentedControlChanged:)
                                   forControlEvents:UIControlEventValueChanged];
    
    [self updateDataSource];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.currentDetailChartRange = [[HGSettings defaultSettings] detailChartRange];
    self.currentFullscreenChartRange = [[HGSettings defaultSettings] fullscreenChartRange];
    
    if ([self.currentDetailChartRange isEqualToString:HGChartRangeThreeMonthDaily]) {
        self.detailChartSegmentedControl.selectedSegmentIndex = 0;
    } else {
        self.detailChartSegmentedControl.selectedSegmentIndex = 1;
    }
    
    if ([self.currentFullscreenChartRange isEqualToString:HGChartRangeThreeMonthDaily]) {
        self.fullscreenChartSegmentedControl.selectedSegmentIndex = 0;
    } else if ([self.currentFullscreenChartRange isEqualToString:HGChartRangeOneYearDaily]) {
        self.fullscreenChartSegmentedControl.selectedSegmentIndex = 1;
    } else {
        self.fullscreenChartSegmentedControl.selectedSegmentIndex = 2;
    }
}

- (BOOL)shouldAutorotate
{
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

- (void)updateDataSource
{
    NSDictionary *dictionary = @{};
    NSMutableArray *sections = [@[] mutableCopy];
    NSMutableArray *rows = [@[] mutableCopy];
    
    dictionary = @{ @"text" : @"Default Range",
                    @"key" : @"detail_chart" };
    
    [rows addObject:dictionary];
    
    [sections addObject:@{ @"title" : @"Position Detail", @"rows" : rows }];
    
    rows = [@[] mutableCopy];
    
    dictionary = @{ @"text" : @"Default Range",
                    @"key" : @"fullscreen_chart" };
    
    [rows addObject:dictionary];
    
    [sections addObject:@{ @"title" : @"Fullscreen Chart" , @"rows" : rows }];
    
    rows = [@[] mutableCopy];
    
    dictionary = @{ @"text" : @"Disclaimer And Guide",
                    @"key" : @"disclaimer",
                    @"type" : @"button" };
    
    [rows addObject:dictionary];
    
    
    NSString *versionStr = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    [sections addObject:@{ @"rows" : rows,
                           @"footer" : [NSString stringWithFormat:@"Mutual Fund Signals (%@)", versionStr] }];
    
    self.dataSource = sections;
}

#pragma mark - Selector Methods

- (void)detailSegmentedControlChanged:(UISegmentedControl *)segmentedControl
{
    NSString *chartRange = nil;
    if (segmentedControl.selectedSegmentIndex == 0) {
        chartRange = HGChartRangeThreeMonthDaily;
    } else {
        chartRange = HGChartRangeOneYearDaily;
    }
    
    [Flurry logEvent:kAnalyticsSettingsSelectPositionRange withParameters:@{ kAnalyticsParameterKeyType : chartRange }];

    self.currentDetailChartRange = chartRange;
    [[HGSettings defaultSettings] setDetailChartRange:self.currentDetailChartRange];
}

- (void)fullscreenChartSegmentedControlChanged:(UISegmentedControl *)segmentedControl
{
    NSString *chartRange = nil;
    if (segmentedControl.selectedSegmentIndex == 0) {
        chartRange = HGChartRangeThreeMonthDaily;
    } else if (segmentedControl.selectedSegmentIndex == 1) {
        chartRange = HGChartRangeOneYearDaily;
    } else {
        chartRange = HGChartRangeTenYearWeekly;
    }
    
    [Flurry logEvent:kAnalyticsSettingsSelectFullChartRange withParameters:@{ kAnalyticsParameterKeyType : chartRange }];

    self.currentFullscreenChartRange = chartRange;
    [[HGSettings defaultSettings] setFullscreenChartRange:self.currentFullscreenChartRange];
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
    static NSString *FullscreenChartIdentifier = @"FullscreenChartcell";
    static NSString *ButtonIdentifier = @"ButtonCell";
    
    NSDictionary *dictionary = self.dataSource[indexPath.section][@"rows"][indexPath.row];
    NSString *key = dictionary[@"key"];
    NSString *type = dictionary[@"type"];
    
    if ([type isEqualToString:@"button"]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ButtonIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ButtonIdentifier];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
        }
        
        cell.textLabel.text = dictionary[@"text"];
        
        return cell;
    }
    
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
    
    if ([key isEqualToString:@"fullscreen_chart"]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:FullscreenChartIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:FullscreenChartIdentifier];
            cell.textLabel.font = [UIFont systemFontOfSize:14.0];
            cell.accessoryView = self.fullscreenChartSegmentedControl;
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
    
    NSDictionary *dictionary = self.dataSource[indexPath.section][@"rows"][indexPath.row];
    NSString *key = dictionary[@"key"];
    
    if ([key isEqualToString:@"disclaimer"]) {
        IntroViewController *introViewController = [[IntroViewController alloc] init];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:introViewController];
        navController.navigationBarHidden = YES;
        navController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        [self.navigationController presentViewController:navController animated:NO completion:nil];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDictionary *dictionary = self.dataSource[section];
    return dictionary[@"title"];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSDictionary *dictionary = self.dataSource[section];
    return dictionary[@"footer"];
}

@end

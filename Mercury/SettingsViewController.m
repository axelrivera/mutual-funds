//
//  SettingsViewController.m
//  Mercury
//
//  Created by Axel Rivera on 2/22/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "SettingsViewController.h"

#import <Social/Social.h>
#import "GuideViewController.h"
#import "MailComposerManager.h"

@interface SettingsViewController () <MailComposerManagerDelegate>

@property (strong, nonatomic) MailComposerManager *mailManager;

@end

@implementation SettingsViewController

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"Settings";
        
        _products = @[];

        self.tabBarItem.image = [UIImage imageNamed:@"gear"];
        self.tabBarItem.selectedImage = [UIImage imageNamed:@"gear-selected"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.backgroundColor = [UIColor hg_mainBackgroundColor];
    
    self.mailManager = [[MailComposerManager alloc] init];
    self.mailManager.delegate = self;
    
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

    self.equityWarningSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    self.equityWarningSwitch.on = [[HGSettings defaultSettings] showEquityWarning];
    [self.equityWarningSwitch addTarget:self action:@selector(equityWarningChanged:) forControlEvents:UIControlEventValueChanged];
    
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

#ifndef ADHOC
    if (IsEmpty(self.products)) {
        [[MercuryStoreManager sharedInstance] requestProductsWithCompletion:^(BOOL success, NSArray *products) {
            if (success) {
                self.products = products;

                NSRange deleteRange = NSMakeRange(0, [self.dataSource count]);

                [self updateDataSource];

                NSRange insertRange = NSMakeRange(0, [self.dataSource count]);

                [self.tableView beginUpdates];

                [self.tableView deleteSections:[NSIndexSet indexSetWithIndexesInRange:deleteRange]
                              withRowAnimation:UITableViewRowAnimationFade];

                [self.tableView insertSections:[NSIndexSet indexSetWithIndexesInRange:insertRange]
                              withRowAnimation:UITableViewRowAnimationFade];

                [self.tableView endUpdates];
            }
        }];
    }
#endif

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(productPurchased:)
                                                 name:StoreManagerProductPurchasedNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:StoreManagerProductPurchasedNotification object:nil];
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
    NSMutableArray *rows = nil;
    
    if (!IsEmpty(self.products)) {
        rows = [@[] mutableCopy];
        
        for (SKProduct *product in self.products) {
            NSString *text = product.localizedTitle;
            NSString *detail = product.localizedDescription;
            NSString *price = [[NSNumberFormatter hg_storePriceFormatterWithLocale:product.priceLocale]
                               stringFromNumber:product.price];
            
            dictionary = @{ @"text" : text,
                            @"detail" : detail,
                            @"price" : price,
                            @"type" : @"product",
                            @"height" : @(64.0) };
            
            [rows addObject:dictionary];
        }
        
        dictionary = @{ @"text" : @"Restore Purchases", @"type" : @"button", @"key" : @"restore_purchase" };

        [rows addObject:dictionary];

        [sections addObject:@{ @"title" : @"In App Purchases", @"rows" : rows }];
    }

    rows = [@[] mutableCopy];
    
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

    dictionary = @{ @"text" : @"Show equity warning when adding\na position.",
                    @"key" : @"equity_warning",
                    @"height" : @(54.0) };

    [rows addObject:dictionary];

    [sections addObject:@{ @"title" : @"Other", @"rows" : rows }];
    
    rows = [@[] mutableCopy];
    
    dictionary = @{ @"text" : @"Send Feedback", @"type" : @"button", @"key" : @"support_feedback" };
    [rows addObject:dictionary];
    
    dictionary = @{ @"text" : @"Report a Problem", @"type" : @"button", @"key" : @"support_problem" };
    [rows addObject:dictionary];
    
    [sections addObject:@{ @"title" : @"Feedback", @"rows" : rows }];
    
    rows = [@[] mutableCopy];
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        dictionary = @{ @"text" : @"Facebook", @"type" : @"button", @"key" : @"share_facebook" };
        [rows addObject:dictionary];
    }
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        dictionary = @{ @"text" : @"Twitter", @"type" : @"button", @"key" : @"share_twitter" };
        [rows addObject:dictionary];
    }
    
    dictionary = @{ @"text" : @"E-mail", @"type" : @"button", @"key" : @"share_email" };
    [rows addObject:dictionary];
    
    [sections addObject:@{ @"title" : @"Share", @"rows" : rows }];
    
    rows = [@[] mutableCopy];
    
    dictionary = @{ @"text" : @"Show Guide",
                    @"key" : @"guide",
                    @"type" : @"button" };
    
    [rows addObject:dictionary];
    
    
    NSString *versionStr = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    [sections addObject:@{ @"rows" : rows,
                           @"footer" : [NSString stringWithFormat:@"Copyright © 2014 Axel Rivera. Mutual Fund Signals (%@)", versionStr] }];
    
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

- (void)equityWarningChanged:(UISwitch *)mySwitch
{
    [[HGSettings defaultSettings] setShowEquityWarning:mySwitch.on];
}

- (void)purchaseAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    SKProduct *product = self.products[button.tag];

    [Flurry logEvent:kAnalyticsStoreBuyProdctAttempt
      withParameters:@{ kAnalyticsParameterKeyType : product.productIdentifier }];

    DLog(@"Buying %@...", product.productIdentifier);
    [[MercuryStoreManager sharedInstance] buyProduct:product];
}

- (void)productPurchased:(NSNotification *)notification
{
    NSString *productIdentifier = notification.object;

    DLog(@"Product Purchased Notification: %@", productIdentifier);

    [Flurry logEvent:kAnalyticsStoreBuyProduct withParameters:@{ kAnalyticsParameterKeyType : productIdentifier }];

    if ([[MercuryStoreManager sharedInstance] purchasedAdRemoval]) {
        [[MercuryBannerManager sharedInstance] destroyBanner];
    }

    [self.products enumerateObjectsUsingBlock:^(SKProduct * product, NSUInteger index, BOOL *stop) {
        if ([product.productIdentifier isEqualToString:productIdentifier]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            *stop = YES;
        }
    }];
}

#pragma mark - MailComposerManagerDelegate Methods

- (void)mailComposerManagerDelegateWillFinish:(MailComposerManager *)manager
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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
    static NSString *EquityWarningIdentifier = @"EquityWarningCell";
    static NSString *ButtonIdentifier = @"ButtonCell";
    static NSString *ProductIdentifier = @"ProductCell";
    
    NSDictionary *dictionary = self.dataSource[indexPath.section][@"rows"][indexPath.row];
    NSString *key = dictionary[@"key"];
    NSString *type = dictionary[@"type"];
    
    if ([type isEqualToString:@"button"]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ButtonIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ButtonIdentifier];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.textColor = [UIColor hg_highlightColor];
        }
        
        cell.textLabel.text = dictionary[@"text"];
        
        return cell;
    }

    if ([type isEqualToString:@"product"]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ProductIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ProductIdentifier];
            cell.textLabel.font = [UIFont systemFontOfSize:14.0];
            cell.textLabel.textColor = [UIColor blackColor];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
            cell.detailTextLabel.textColor = [UIColor grayColor];
            cell.detailTextLabel.numberOfLines = 2.0;
        }

        SKProduct *product = self.products[indexPath.row];

        if ([[MercuryStoreManager sharedInstance] productPurchased:product.productIdentifier]) {
            cell.accessoryView = nil;
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
            button.tag = indexPath.row;
            [button setTitle:[NSString stringWithFormat:@"%@ Buy", dictionary[@"price"]] forState:UIControlStateNormal];
            [button sizeToFit];

            [button addTarget:self action:@selector(purchaseAction:) forControlEvents:UIControlEventTouchUpInside];

            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.accessoryView = button;
        }

        cell.textLabel.text = dictionary[@"text"];
        cell.detailTextLabel.text = dictionary[@"detail"];

        cell.selectionStyle = UITableViewCellSelectionStyleNone;

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
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
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
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }

    if ([key isEqualToString:@"equity_warning"]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:EquityWarningIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:EquityWarningIdentifier];
            cell.textLabel.font = [UIFont systemFontOfSize:14.0];
            cell.textLabel.numberOfLines = 2;
            cell.accessoryView = self.equityWarningSwitch;
        }

        cell.textLabel.text = dictionary[@"text"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

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
    
    NSString *versionStr = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *osVersionStr = [UIDevice currentDevice].systemVersion;
    
    NSString *shareText = @"Check out the App Mutual Fund Signals to find out if you should Sell or Hold your Mutual Fund positions. #ios";
    NSString *supportText = [NSString stringWithFormat:@"\n\n\n----------\nApp Version: %@\niOS: %@", versionStr, osVersionStr];
    
    if ([key isEqualToString:@"guide"]) {
        GuideViewController *guideController = [GuideViewController skipGuideViewController];

        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:guideController];
        navController.navigationBarHidden = YES;
        navController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        [self.navigationController presentViewController:navController animated:YES completion:nil];
    } else if ([key isEqualToString:@"restore_purchase"]) {
        [Flurry logEvent:kAnalyticsStoreRestorePurchases];

        [[MercuryStoreManager sharedInstance] restoreCompletedTransactions];
    } else if ([key isEqualToString:@"share_facebook"]) {
        [Flurry logEvent:kAnalyticsShareFacebook];

        SLComposeViewController *fbSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [fbSheet setInitialText:shareText];
        [fbSheet addURL:[NSURL URLWithString:MERCURY_APPSTORE_LINK]];
        [self presentViewController:fbSheet animated:YES completion:nil];
    } else if ([key isEqualToString:@"share_twitter"]) {
        [Flurry logEvent:kAnalyticsShareTwitter];

        SLComposeViewController *twitterSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [twitterSheet setInitialText:shareText];
        [twitterSheet addURL:[NSURL URLWithString:MERCURY_APPSTORE_LINK]];
        [self presentViewController:twitterSheet animated:YES completion:nil];
    } else if ([key isEqualToString:@"share_email"]) {
        [Flurry logEvent:kAnalyticsShareEmail];

        NSString *emailText = [NSString stringWithFormat:@"Hi,\n\nCheck out this App called Mutual Fund Signals to find out "
                               "if you should Sell or Buy your current Mutual Fund positions.\n\nDownload it from the App Store.\n%@", MERCURY_APPSTORE_LINK];
        
        [self.mailManager displayComposerSheetTo:nil
                                         subject:@"Mutual Fund Signals for iPhone"
                                            body:emailText
                                          isHTML:NO
                                          target:self];
    } else if ([key isEqualToString:@"support_feedback"]) {
        [Flurry logEvent:kAnalyticsSupportFeedback];

        [self.mailManager displayComposerSheetTo:@[ MERCURY_SUPPORT_EMAIL ]
                                         subject:@"Feedback: Mutual Fund Signals"
                                            body:supportText
                                          isHTML:NO
                                          target:self];
    } else if ([key isEqualToString:@"support_problem"]) {
        [Flurry logEvent:kAnalyticsSupportProblem];

        [self.mailManager displayComposerSheetTo:@[ MERCURY_SUPPORT_EMAIL ]
                                         subject:@"Problem: Mutual Fund Signals"
                                            body:supportText
                                          isHTML:NO
                                          target:self];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44.0;
    NSDictionary *dictionary = self.dataSource[indexPath.section][@"rows"][indexPath.row];
    if (dictionary[@"height"]) {
        height = [dictionary[@"height"] doubleValue];
    }
    return height;
}

@end

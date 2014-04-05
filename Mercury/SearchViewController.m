//
//  SearchViewController.m
//  Mercury
//
//  Created by Axel Rivera on 3/4/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "SearchViewController.h"

#import "SearchCell.h"
#import "PositionsViewController.h"
#import "PositionDetailViewController.h"
#import <MBProgressHUD.h>

@interface SearchViewController () <UISearchDisplayDelegate>

@property (strong, nonatomic) UISearchDisplayController *searchController;
@property (strong, nonatomic) UISearchBar *searchBar;

@end

@implementation SearchViewController

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (instancetype)initWithTickerType:(HGTickerType)tickerType
{
    self = [self init];
    if (self) {
        _tickerType = tickerType;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    self.searchBar.tintColor = [UIColor hg_highlightColor];
    self.searchBar.placeholder = @"Name or Symbol";

    self.searchController = [[UISearchDisplayController alloc]
                        initWithSearchBar:self.searchBar contentsController:self];
    
    self.searchController.delegate = self;
    self.searchController.searchResultsDataSource = self;
    self.searchController.searchResultsDelegate = self;
    self.searchController.displaysSearchBarInNavigationBar = YES;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(cancelAction:)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.searchBar becomeFirstResponder];
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

#pragma mark - Selector Methods

- (void)cancelAction:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sections = 1;
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = [self.searchDataSource count];
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    SearchCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SearchCell alloc] initWithReuseIdentifier:CellIdentifier];
    }
    
    HGTicker *ticker = self.searchDataSource[indexPath.row];
    
    NSString *name = [ticker name];
    NSString *symbol = ticker.symbol;

    if (IsEmpty(name)) {
        name = ticker.symbol;
        symbol = nil;
    }
    
    cell.nameLabel.text = name;
    cell.symbolLabel.text = symbol;
    cell.typeLabel.text = ticker.positionType;
    
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if ([[ticker.positionType uppercaseString] isEqualToString:@"ETF"] ||
        [[ticker.positionType uppercaseString] isEqualToString:@"FUND"])
    {
        cell.typeLabel.textColor = [UIColor hg_greenColor];
    } else {
        cell.typeLabel.textColor = [UIColor grayColor];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    HGTicker *myTicker = self.searchDataSource[indexPath.row];
    
    [[MercuryData sharedData] fetchPositionForSymbol:myTicker.symbol completion:^(HGPosition *position, NSError *error) {
        if (error) {
            [Flurry logError:kAnalyticsPositionSearchError message:nil error:error];
            return;
        }
        
        PositionDetailViewControllerSaveBlock saveBlock = ^(HGTicker *ticker) {
            if (ticker) {
                [self.navigationController dismissViewControllerAnimated:YES completion:^{
                    [[MercuryData sharedData] addTicker:ticker
                                             tickerType:ticker.tickerType
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
                         
                         NSString *tickerKey = [MercuryData keyForTickerType:ticker.tickerType];
                         NSDictionary *userInfo = @{ @"ticker_key" : tickerKey,
                                                     @"ticker" : ticker };
                         
                         
                         NSString *description = IsEmpty(ticker.positionType) ? @"" : ticker.positionType;
                         
                         [Flurry logEvent:kAnalyticsSavePosition
                           withParameters:@{ kAnalyticsParameterKeyType : tickerKey,
                                             @"DESCRIPTION" : description }];
                         
                         [[NSNotificationCenter defaultCenter] postNotificationName:PositionSavedNotification
                                                                             object:nil
                                                                           userInfo:userInfo];
                     }];
                }];
            }
        };
        
        HGTicker *ticker = [HGTicker tickerWithType:self.tickerType symbol:myTicker.symbol];
        ticker.tickerName = myTicker.tickerName;
        ticker.exchange = myTicker.exchange;
        ticker.positionType = myTicker.positionType;
        ticker.position = position;
        
        PositionDetailViewController *controller = [[PositionDetailViewController alloc] initWithTicker:ticker
                                                                                              allowSave:YES];
        controller.saveBlock = saveBlock;
        
        [Flurry logEvent:kAnalyticsPositionDetailSelected
          withParameters:@{ kAnalyticsParameterKeyType : [MercuryData keyForTickerType:self.tickerType],
                            @"SEARCH" : @"YES" }];
        
        self.navigationController.navigationBar.topItem.prompt = nil;
        [self.navigationController pushViewController:controller animated:YES];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54.0;
}

#pragma mark - UISearchDisplayDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    if (IsEmpty(searchString)) {
        return NO;
    }
    
    [[YahooAPIClient sharedClient] fetchTickersForString:searchString completion:^(NSArray *tickers, NSError *error) {
        if (error) {
            return;
        }
        
        self.searchDataSource = tickers;
        [self.searchController.searchResultsTableView reloadData];
    }];
    
    return NO;
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    
}

@end

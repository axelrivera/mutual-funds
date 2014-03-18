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

- (void)updateDataSource;

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
    self.searchBar.prompt = @"Select Existing / Enter New Name or Symbol";
    
    self.searchController = [[UISearchDisplayController alloc]
                        initWithSearchBar:self.searchBar contentsController:self];
    
    self.searchController.delegate = self;
    self.searchController.searchResultsDataSource = self;
    self.searchController.searchResultsDelegate = self;
    self.searchController.displaysSearchBarInNavigationBar = YES;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(cancelAction:)];
    
    [self updateDataSource];
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
    NSMutableArray *sections = [@[] mutableCopy];
    NSArray *myPositions = nil;
    NSArray *myWatchlist = nil;
    NSArray *myIndexes = nil;
    
    if (self.tickerType == HGTickerTypeMyPositions) {
        myWatchlist = [[MercuryData sharedData] arrayForTickerType:HGTickerTypeMyWatchlist];
        myIndexes = [[MercuryData sharedData] arrayForTickerType:HGTickerTypeMyIndexes];
    } else if (self.tickerType == HGTickerTypeMyWatchlist) {
        myPositions = [[MercuryData sharedData] arrayForTickerType:HGTickerTypeMyPositions];
        myIndexes = [[MercuryData sharedData] arrayForTickerType:HGTickerTypeMyIndexes];
    } else if (self.tickerType == HGTickerTypeMyIndexes) {
        myPositions = [[MercuryData sharedData] arrayForTickerType:HGTickerTypeMyPositions];
        myWatchlist = [[MercuryData sharedData] arrayForTickerType:HGTickerTypeMyWatchlist];
    }
    
    if (!IsEmpty(myPositions)) {
        [sections addObject:@{ @"title" : @"My Positions", @"rows" : [NSArray arrayWithArray:myPositions] }];
    }
    
    if (!IsEmpty(myWatchlist)) {
        [sections addObject:@{ @"title" : @"Watchlist", @"rows" : [NSArray arrayWithArray:myWatchlist] }];
    }
    
    if (!IsEmpty(myIndexes)) {
        [sections addObject:@{ @"title" : @"Indexes", @"rows" : [NSArray arrayWithArray:myIndexes] }];
    }
    
    self.dataSource = sections;
}

#pragma mark - Selector Methods

- (void)cancelAction:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sections = 0;
    if (tableView == self.tableView) {
        sections = [self.dataSource count];
    } else {
        sections = 1;
    }
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    if (tableView == self.tableView) {
        rows = [self.dataSource[section][@"rows"] count];
    } else {
        rows = [self.searchDataSource count];
    }
    
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    SearchCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SearchCell alloc] initWithReuseIdentifier:CellIdentifier];
    }
    
    HGTicker *ticker = nil;
    
    if (tableView == self.tableView) {
        ticker = self.dataSource[indexPath.section][@"rows"][indexPath.row];
    } else {
        ticker = self.searchDataSource[indexPath.row];
    }
    
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
    
    HGTicker *myTicker = nil;
    
    if (tableView == self.tableView) {
        myTicker = self.dataSource[indexPath.section][@"rows"][indexPath.row];
    } else {
        myTicker = self.searchDataSource[indexPath.row];
    }
    
    [[MercuryData sharedData] fetchPositionForSymbol:myTicker.symbol completion:^(HGPosition *position, NSError *error) {
        if (error) {
            [Flurry logError:kAnalyticsPositionSearchError message:nil error:error];
            return;
        }
        
        PositionDetailViewControllerSaveBlock saveBlock = ^(HGTicker *ticker) {
            if (ticker) {
                [self.navigationController dismissViewControllerAnimated:YES completion:^{
                    [[MercuryData sharedData] addTicker:ticker tickerType:ticker.tickerType];
                    
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
        
        [self.navigationController pushViewController:controller animated:YES];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54.0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    if (tableView == self.tableView) {
        title = self.dataSource[section][@"title"];
    }
    return title;
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

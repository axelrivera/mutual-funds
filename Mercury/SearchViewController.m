//
//  SearchViewController.m
//  Mercury
//
//  Created by Axel Rivera on 3/4/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "SearchViewController.h"

#import "PositionsViewController.h"
#import "PositionDetailViewController.h"

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Selector Methods

- (void)cancelAction:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
        cell.detailTextLabel.textColor = [UIColor grayColor];
    }
    
    HGTicker *ticker = self.dataSource[indexPath.row];
    
    cell.textLabel.text = ticker.tickerName;
    cell.detailTextLabel.text = ticker.symbol;
    
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    HGTicker *searchTicker = self.dataSource[indexPath.row];
    
    [[MercuryData sharedData] fetchPositionForSymbol:searchTicker.symbol completion:^(HGPosition *position, NSError *error) {
        if (error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error searching symbol"
                                                                message:@"Error searching symbol"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
            return;
        }
        
        PositionDetailViewControllerSaveBlock saveBlock = ^(HGTicker *ticker) {
            if (ticker) {
                [self.navigationController dismissViewControllerAnimated:YES completion:^{
                    NSDictionary *userInfo = @{ @"ticker_type" : [NSNumber numberWithInteger:self.tickerType],
                                                @"ticker" : ticker };
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:PositionSavedNotification
                                                                        object:nil
                                                                      userInfo:userInfo];
                }];
            }
        };
        
        HGTicker *ticker = [HGTicker tickerWithType:self.tickerType symbol:searchTicker.symbol];
        ticker.tickerName = searchTicker.tickerName;
        ticker.exchange = searchTicker.exchange;
        ticker.positionType = searchTicker.positionType;
        ticker.position = position;
        
        PositionDetailViewController *controller = [[PositionDetailViewController alloc] initWithTicker:ticker
                                                                                              allowSave:YES];
        controller.saveBlock = saveBlock;        
        [self.navigationController pushViewController:controller animated:YES];
    }];
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
        
        self.dataSource = tickers;
        [self.searchController.searchResultsTableView reloadData];
    }];
    
    return NO;
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    
}

@end

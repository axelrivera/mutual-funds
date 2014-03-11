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
    self.searchBar.prompt = @"Enter Name or Symbol";
    
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
    
    SearchCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SearchCell alloc] initWithReuseIdentifier:CellIdentifier];
    }
    
    HGTicker *ticker = self.dataSource[indexPath.row];
    
    cell.nameLabel.text = ticker.tickerName;
    cell.symbolLabel.text = ticker.symbol;
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
    
    HGTicker *searchTicker = self.dataSource[indexPath.row];
    
    [[MercuryData sharedData] fetchPositionForSymbol:searchTicker.symbol completion:^(HGPosition *position, NSError *error) {
        if (error) {
            [Flurry logError:kAnalyticsPositionSearchError message:nil error:error];
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
        
        self.dataSource = tickers;
        [self.searchController.searchResultsTableView reloadData];
    }];
    
    return NO;
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    
}


@end

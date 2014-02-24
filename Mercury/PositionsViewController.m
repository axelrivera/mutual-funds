//
//  MainViewController.m
//  Mercury
//
//  Created by Axel Rivera on 2/21/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "PositionsViewController.h"

#import <UIView+AutoLayout.h>
#import "PositionDetailViewController.h"
#import "PositionDisplayCell.h"

@interface PositionsViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UITableViewController *tableViewController;

@property (strong, nonatomic) UIBarButtonItem *addButton;
@property (strong, nonatomic) UIBarButtonItem *editButton;
@property (strong, nonatomic) UIBarButtonItem *editDoneButton;
@property (strong, nonatomic) UIBarButtonItem *clearButton;

@end

@implementation PositionsViewController

- (instancetype)init
{
    return [self initWithTickerType:HGTickerTypeWatchlist];
}

- (instancetype)initWithTickerType:(HGTickerType)tickerType
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _tickerType = tickerType;
        
        if (tickerType == HGTickerTypeWatchlist) {
            self.title = @"Watchlist";
        } else {
            self.title = @"My Positions";
        }

        UIImage *tabImage = nil;
        UIImage *tabImageSelected = nil;
        if (tickerType == HGTickerTypeWatchlist) {
            tabImage = [UIImage imageNamed:@"graph"];
            tabImageSelected = [UIImage imageNamed:@"graph-selected"];
        } else {
            tabImage = [UIImage imageNamed:@"top-list"];
            tabImageSelected = [UIImage imageNamed:@"top-list-selected"];
        }

        self.tabBarItem.image = tabImage;
        self.tabBarItem.selectedImage = tabImageSelected;
        
        _dataSource = @[];
    }
    return self;
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    
    [self.view addSubview:self.tableView];
    
    self.tableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    [self addChildViewController:self.tableViewController];
    
    self.tableViewController.refreshControl = [[UIRefreshControl alloc] init];
    self.tableViewController.refreshControl.tintColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    
    [self.tableViewController.refreshControl addTarget:self
                                                action:@selector(reloadAction:)
                                      forControlEvents:UIControlEventValueChanged];
    
    self.tableViewController.tableView = self.tableView;
    
    self.editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                    target:self
                                                                    action:@selector(editWatchlistAction:)];
    
    self.addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                    target:self
                                                                    action:@selector(addAction:)];
    
    self.editDoneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                        target:self
                                                                        action:@selector(editDoneAction:)];

    self.clearButton = [[UIBarButtonItem alloc] initWithTitle:@"Delete All"
                                                        style:UIBarButtonItemStylePlain
                                                       target:self
                                                       action:@selector(clearAllAction:)];
    
    [self.navigationItem setLeftBarButtonItem:self.editButton animated:NO];
    [self.navigationItem setRightBarButtonItem:self.addButton animated:NO];

    if (self.tickerType == HGTickerTypeMyPositions) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(myPositionsReloaded:)
                                                     name:ReloadMyPositionsNotification
                                                   object:nil];
    }
}

- (void)viewDidLayoutSubviews
{
    [self.tableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    
    [self.view layoutSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (IsEmpty(self.dataSource)) {
        [self reloadPositions];
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

- (void)dealloc
{
    if (self.tickerType == HGTickerTypeMyPositions) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ReloadMyPositionsNotification object:nil];
    }
}

#pragma mark - Public methods

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
    
    if (editing) {
        [self.navigationItem setLeftBarButtonItem:self.editDoneButton animated:YES];
        [self.navigationItem setRightBarButtonItem:self.clearButton animated:YES];
    } else {
        [self.navigationItem setLeftBarButtonItem:self.editButton animated:YES];
        [self.navigationItem setRightBarButtonItem:self.addButton animated:YES];
    }
}

#pragma mark - Private Methods

- (void)reloadPositions
{
    HGTickersCompletionBlock completionBlock = ^(NSArray *tickers, NSError *error) {
        [self.tableViewController.refreshControl endRefreshing];
        
        if (error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Mercury"
                                                                message:@"Error loading positions"
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
            return;
        }
        
        self.dataSource = tickers;
        [self.tableView reloadData];
    };
    
    if (self.tickerType == HGTickerTypeWatchlist) {
        [[MercuryData sharedData] fetchWatchlistWithCompletion:completionBlock];
    } else {
        [[MercuryData sharedData] fetchMyPositionsWithCompletion:completionBlock];
    }
}

#pragma mark - Selector Methods

- (void)addAction:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Ticker Search"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Search", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}

- (void)editWatchlistAction:(id)sender
{
    [self setEditing:YES animated:YES];
}

- (void)editDoneAction:(id)sender
{
    [self setEditing:NO animated:YES];
}

- (void)clearAllAction:(id)sender
{

}

- (void)reloadAction:(UIRefreshControl *)refreshControl
{
    [self reloadPositions];
}

- (void)myPositionsReloaded:(NSNotification *)notification
{
    self.dataSource = [MercuryData sharedData].myPositions;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    PositionDisplayCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[PositionDisplayCell alloc] initWithReuseIdentifier:CellIdentifier];
    }
    
    HGTicker *ticker = self.dataSource[indexPath.row];
    
    cell.closeLabel.text = ticker.position.close;
    cell.nameLabel.text = ticker.position.name;
    cell.symbolLabel.text = ticker.position.symbol;
    
    [cell setNeedsUpdateConstraints];
    
    return cell;
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    HGTicker *ticker = self.dataSource[indexPath.row];
    PositionDetailViewController *detailController = [[PositionDetailViewController alloc] initWithTicker:ticker];
    detailController.hidesBottomBarWhenPushed = YES;

    [self.navigationController pushViewController:detailController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 76.0;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    
}

#pragma mark - UITextFieldDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        NSString *symbol = [textField.text uppercaseString];

        [[YahooAPIClient sharedClient] fetchPositionsForSymbols:@[ symbol ]
                                                     completion:^(NSArray *positions, NSError *error)
        {
            if (error || IsEmpty(positions)) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error searching symbol"
                                                                    message:@"Error searching symbol"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                [alertView show];
                return;
            }

            PositionDetailViewControllerSaveBlock saveBlock = ^(HGTicker *ticker) {
                if (self.tickerType == HGTickerTypeWatchlist) {
                    [[MercuryData sharedData].watchlist addObject:ticker];
                    self.dataSource = [MercuryData sharedData].watchlist;
                } else {
                    [[MercuryData sharedData].myPositions addObject:ticker];
                    self.dataSource = [MercuryData sharedData].myPositions;
                }

                [self.tableView reloadData];
            };

            HGTicker *ticker = [HGTicker tickerWithType:self.tickerType symbol:symbol];
            ticker.position = positions[0];

            PositionDetailViewController *controller = [[PositionDetailViewController alloc] initWithTicker:ticker
                                                                                                  allowSave:YES];
            controller.saveBlock = saveBlock;
            controller.hidesBottomBarWhenPushed = YES;

            [self.navigationController pushViewController:controller animated:YES];
        }];
    }
}

@end

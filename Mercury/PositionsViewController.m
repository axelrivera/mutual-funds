//
//  MainViewController.m
//  Mercury
//
//  Created by Axel Rivera on 2/21/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "PositionsViewController.h"

#import <UIView+AutoLayout.h>
#import "SearchViewController.h"
#import "PositionDetailViewController.h"
#import "PositionDisplayCell.h"

@interface PositionsViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) UITableViewController *tableViewController;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) UIBarButtonItem *addButton;
@property (strong, nonatomic) UIBarButtonItem *editButton;
@property (strong, nonatomic) UIBarButtonItem *editDoneButton;
@property (strong, nonatomic) UIBarButtonItem *clearButton;

@end

@implementation PositionsViewController

- (instancetype)init
{
    return [self initWithTickerType:HGTickerTypeMyIndexes];
}

- (instancetype)initWithTickerType:(HGTickerType)tickerType
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _tickerType = tickerType;
        
        if (tickerType == HGTickerTypeMyIndexes) {
            self.title = @"Indexes";
        } else if (tickerType == HGTickerTypeMyWatchlist) {
            self.title = @"Watchlist";
        } else {
            self.title = @"My Positions";
        }

        NSString *imageName = nil;
        NSString *selectedImageName = nil;
        
        if (tickerType == HGTickerTypeMyIndexes) {
            imageName = @"globe";
            selectedImageName = @"globe-selected";
        } else if (tickerType == HGTickerTypeMyWatchlist) {
            imageName = @"graph";
            selectedImageName = @"graph-selected";
        } else {
            imageName = @"top-list";
            selectedImageName = @"top-list-selected";
        }

        self.tabBarItem.image = [UIImage imageNamed:imageName];
        self.tabBarItem.selectedImage = [UIImage imageNamed:selectedImageName];
        
        _dataSource = [@[] mutableCopy];
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
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    
    [self.refreshControl addTarget:self
                            action:@selector(reloadAction:)
                  forControlEvents:UIControlEventValueChanged];
    
    self.tableViewController.tableView = self.tableView;
    
    self.tableViewController.refreshControl = self.refreshControl;
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(allPositionsReloaded:)
                                                 name:AllPositionsReloadedNotification
                                               object:nil];
    
    self.dataSource = [NSMutableArray arrayWithArray:[[MercuryData sharedData] arrayForTickerType:self.tickerType]];
    if (self.tickerType == HGTickerTypeMyPositions) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(myPositionsReloaded:)
                                                     name:MyPositionsReloadedNotification
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
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self setEditing:NO animated:animated];
    
    if ([self.refreshControl isRefreshing]) {
        [self.refreshControl endRefreshing];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AllPositionsReloadedNotification object:nil];
    
    if (self.tickerType == HGTickerTypeMyPositions) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MyPositionsReloadedNotification object:nil];
    }
}

#pragma mark - Public methods

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
    
    if (editing) {
        self.tableViewController.refreshControl = nil;
        [self.navigationItem setLeftBarButtonItem:self.editDoneButton animated:YES];
        [self.navigationItem setRightBarButtonItem:self.clearButton animated:YES];
    } else {
        self.tableViewController.refreshControl = self.refreshControl;
        [self.navigationItem setLeftBarButtonItem:self.editButton animated:YES];
        [self.navigationItem setRightBarButtonItem:self.addButton animated:YES];
    }
}

#pragma mark - Private Methods

- (void)reloadPositions
{
    [Flurry logEvent:kAnalyticsRefreshPositions
      withParameters:@{ kAnalyticsParameterKeyType : [MercuryData keyForTickerType:self.tickerType] }];
    
    HGTickersCompletionBlock completionBlock = ^(NSArray *tickers, NSError *error) {
        [self.refreshControl endRefreshing];
        
        if (error) {
            [Flurry logError:kAnalyticsPositionsRefreshError message:nil error:error];
            return;
        }
        
        self.dataSource = [[NSMutableArray alloc] initWithArray:tickers];
        [self.tableView reloadData];
    };
    
    if (self.tickerType == HGTickerTypeMyIndexes) {
        if ([MercuryData sharedData].isFetchingMyIndexes) {
            [self.refreshControl endRefreshing];
            return;
        }
    } else if (self.tickerType == HGTickerTypeMyWatchlist) {
        if ([MercuryData sharedData].isFetchingMyWatchlist) {
            [self.refreshControl endRefreshing];
            return;
        }
    } else {
        if ([MercuryData sharedData].isFetchingMyPositions) {
            [self.refreshControl endRefreshing];
            return;
        }
    }
    
    [[MercuryData sharedData] fetchTickerType:self.tickerType completion:completionBlock];
}

#pragma mark - Selector Methods

- (void)addAction:(id)sender
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionSaved:)
                                                 name:PositionSavedNotification
                                               object:nil];
    
    [Flurry logEvent:kAnalyticsAddPosition
      withParameters:@{ kAnalyticsParameterKeyType : [MercuryData keyForTickerType:self.tickerType] }];
    
    SearchViewController *searchController = [[SearchViewController alloc] initWithTickerType:self.tickerType];

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:searchController];
    
    [Flurry logAllPageViews:navController];
    
    [self.navigationController presentViewController:navController animated:YES completion:nil];
    
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Ticker Search"
//                                                        message:nil
//                                                       delegate:self
//                                              cancelButtonTitle:@"Cancel"
//                                              otherButtonTitles:@"Search", nil];
//    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
//    
//    UITextField *textField = [alertView textFieldAtIndex:0];
//    textField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
//    textField.keyboardType = UIKeyboardTypeASCIICapable;
//    textField.autocorrectionType = UITextAutocorrectionTypeNo;
//    
//    [alertView show];
}

- (void)editWatchlistAction:(id)sender
{
    [Flurry logEvent:kAnalyticsEditPositions
      withParameters:@{ kAnalyticsParameterKeyType : [MercuryData keyForTickerType:self.tickerType] }];
    
    [self setEditing:YES animated:YES];
}

- (void)editDoneAction:(id)sender
{
    [self setEditing:NO animated:YES];
}

- (void)clearAllAction:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Delete all positions?"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Delete All"
                                                    otherButtonTitles:nil];
    
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

- (void)reloadAction:(UIRefreshControl *)refreshControl
{
    [self reloadPositions];
}

- (void)myPositionsReloaded:(NSNotification *)notification
{
    self.dataSource = [[NSMutableArray alloc] initWithArray:[[MercuryData sharedData] arrayForTickerType:HGTickerTypeMyPositions]];
    [self.tableView reloadData];
}

- (void)allPositionsReloaded:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSMutableArray *array = nil;
    if (self.tickerType == HGTickerTypeMyIndexes) {
        array = IsEmpty(userInfo[kHGMyIndexes]) ? @[] : userInfo[kHGMyIndexes];
    } else if (self.tickerType == HGTickerTypeMyWatchlist) {
        array = IsEmpty(userInfo[kHGMyWatchlist]) ? @[] : userInfo[kHGMyWatchlist];
    } else {
        array = IsEmpty(userInfo[kHGMyPositions]) ? @[] : userInfo[kHGMyPositions];
    }
    
    self.dataSource = [[NSMutableArray alloc] initWithArray:array];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)positionSaved:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PositionSavedNotification object:nil];
    
    NSDictionary *userInfo = notification.userInfo;
    NSNumber *tickerType = userInfo[@"ticker_type"];
    HGTicker *ticker = userInfo[@"ticker"];
    
    if (tickerType && ticker) {
        if ([tickerType integerValue] == self.tickerType) {
            NSMutableArray *array = [[MercuryData sharedData] arrayForTickerType:[tickerType integerValue]];
            [array addObject:ticker];
            self.dataSource = [NSMutableArray arrayWithArray:array];
            [self.tableView reloadData];
        }
    }
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
    
    cell.symbolLabel.text = ticker.symbol;
    cell.nameLabel.text = [ticker name];
    cell.closeLabel.text = [ticker close];
    cell.changeLabel.text = [ticker priceAndPercentChange];
    
    cell.changeLabel.textColor = [ticker.position colorForChangeType];
    
    return cell;
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    HGTicker *ticker = self.dataSource[indexPath.row];
    PositionDetailViewController *detailController = [[PositionDetailViewController alloc] initWithTicker:ticker];
    detailController.hidesBottomBarWhenPushed = YES;
    
    [Flurry logEvent:kAnalyticsPositionDetailSelected
      withParameters:@{ kAnalyticsParameterKeyType : [MercuryData keyForTickerType:self.tickerType],
                        @"SEARCH" : @"NO" }];

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

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [Flurry logEvent:kAnalyticsRemovePosition
          withParameters:@{ kAnalyticsParameterKeyType : [MercuryData keyForTickerType:self.tickerType] }];
        
        [self.dataSource removeObjectAtIndex:indexPath.row];
        [[MercuryData sharedData] removeTickerAtIndex:indexPath.row tickerType:self.tickerType];
        
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView endUpdates];
        
        if (IsEmpty(self.dataSource)) {
            [self setEditing:NO animated:YES];
        }
    }
}

- (void)tableView:(UITableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)fromIndexPath
      toIndexPath:(NSIndexPath *)toIndexPath
{
    HGTicker *ticker = self.dataSource[fromIndexPath.row];
    
    [self.dataSource removeObjectAtIndex:fromIndexPath.row];
    [self.dataSource insertObject:ticker atIndex:toIndexPath.row];
    
    [[MercuryData sharedData] removeTickerAtIndex:fromIndexPath.row tickerType:self.tickerType];
    [[MercuryData sharedData] insertTicker:ticker atIndex:toIndexPath.row tickerType:self.tickerType];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark - UITextFieldDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        NSString *symbol = [textField.text uppercaseString];
        
        [[MercuryData sharedData] fetchPositionForSymbol:symbol completion:^(HGPosition *position, NSError *error) {
            if (error) {
                [Flurry logError:kAnalyticsPositionFetchError message:nil error:error];
                return;
            }
            
            PositionDetailViewControllerSaveBlock saveBlock = ^(HGTicker *ticker) {
                NSMutableArray *array = [[MercuryData sharedData] arrayForTickerType:self.tickerType];
                [array addObject:ticker];
                self.dataSource = [NSMutableArray arrayWithArray:array];
                
                [self.tableView reloadData];
                [self.navigationController popViewControllerAnimated:YES];
            };
                        
            HGTicker *ticker = [HGTicker tickerWithType:self.tickerType symbol:symbol];
            ticker.position = position;
            
            PositionDetailViewController *controller = [[PositionDetailViewController alloc] initWithTicker:ticker
                                                                                                  allowSave:YES];
            controller.saveBlock = saveBlock;
            controller.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:controller animated:YES];
        }];
    }
}

#pragma mark - UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [Flurry logEvent:kAnalyticsRemoveAllPositions
          withParameters:@{ kAnalyticsParameterKeyType : [MercuryData keyForTickerType:self.tickerType] }];
        
        [self.dataSource removeAllObjects];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [[MercuryData sharedData] removeAllTickersForTickerType:self.tickerType];
        
        [self setEditing:NO animated:YES];
    }
}

@end

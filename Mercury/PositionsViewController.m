//
//  MainViewController.m
//  Mercury
//
//  Created by Axel Rivera on 2/21/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "PositionsViewController.h"

#import <UIView+AutoLayout.h>
#import "UIViewController+Layout.h"
#import "SearchViewController.h"
#import "PositionDetailViewController.h"
#import "PositionDisplayCell.h"
#import "GuideViewController.h"

@interface PositionsViewController () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>

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
        [[MercuryBannerManager sharedInstance] addBannerViewController:self];
        
        _tickerType = tickerType;
        
        self.title = [MercuryData titleForTickerType:tickerType];

        NSString *imageName = nil;
        NSString *selectedImageName = nil;
        
        if (tickerType == HGTickerTypeMyIndexes) {
            imageName = @"globe";
            selectedImageName = @"globe-selected";
        } else if (tickerType == HGTickerTypeMyWatchlist) {
            imageName = @"graph";
            selectedImageName = @"graph-selected";
        } else if (tickerType == HGTickerTypeMyPositions) {
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

    DLog(@"View Did Load: %@", [MercuryData keyForTickerType:self.tickerType]);
    
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

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionSaved:)
                                                 name:PositionSavedNotification
                                               object:nil];
    
    self.dataSource = [NSMutableArray arrayWithArray:[[MercuryData sharedData] arrayForTickerType:self.tickerType]];
    
    if (![[HGSettings defaultSettings] disclaimerShown]) {
        GuideViewController *guideController = [GuideViewController defaultGuideViewController];

        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:guideController];
        navController.navigationBarHidden = YES;
        navController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        [self.navigationController presentViewController:navController animated:NO completion:nil];
    }
}

- (void)viewDidLayoutSubviews
{
    [self.tableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    
    UIEdgeInsets insets = self.tableView.contentInset;
    
    CGRect contentRect = self.view.bounds;
    
    ADBannerView *bannerView = [MercuryBannerManager sharedInstance].bannerView;
    
    if (bannerView) {
        // We only want to modify the banner view itself if this view controller is actually visible to the user.
        // This prevents us from modifying it while it is being displayed elsewhere.
        if (self.isViewLoaded && (self.view.window != nil)) {
            CGRect bannerRect = CGRectZero;
            
            // If configured to support iOS >= 6.0 only, then we want to avoid currentContentSizeIdentifier as it is deprecated.
            // Fortunately all we need to do is ask the banner for a size that fits into the layout area we are using.
            // At this point in this method contentFrame=self.view.bounds, so we'll use that size for the layout.
            bannerRect.size = [[MercuryBannerManager sharedInstance].bannerView sizeThatFits:contentRect.size];
            
            if (bannerView && bannerView.bannerLoaded) {
                bannerRect.origin.y = contentRect.size.height - (bannerRect.size.height + self.bottomOrigin);
                insets.bottom = self.bottomOrigin + bannerRect.size.height;
            } else {
                bannerRect.origin.y = contentRect.size.height;
                insets.bottom = self.bottomOrigin;
            }
            
            [self.view addSubview:bannerView];
            bannerView.frame = bannerRect;
        } else {
            insets.bottom = self.bottomOrigin;
        }
    } else {
        insets.bottom = self.bottomOrigin;
    }
    
    self.tableView.contentInset = insets;
    self.tableView.scrollIndicatorInsets = insets;
    
    [self.view layoutSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view addSubview:[MercuryBannerManager sharedInstance].bannerView];
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
    [[MercuryBannerManager sharedInstance] removeBannerViewController:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AllPositionsReloadedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PositionSavedNotification object:nil];
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

- (void)updateLayout
{
    [UIView animateWithDuration:0.25 animations:^{
        // -viewDidLayoutSubviews will handle positioning the banner such that it is either visible
        // or hidden depending upon whether its bannerLoaded property is YES or NO.  We just need our view
        // to (re)lay itself out so -viewDidLayoutSubviews will be called.
        // You must not call [self.view layoutSubviews] directly.  However, you can flag the view
        // as requiring layout...
        [self.view setNeedsLayout];
        // ...then ask it to lay itself out immediately if it is flagged as requiring layout...
        [self.view layoutIfNeeded];
        // ...which has the same effect.
    }];
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
    [Flurry logEvent:kAnalyticsAddPosition
      withParameters:@{ kAnalyticsParameterKeyType : [MercuryData keyForTickerType:self.tickerType] }];
    
    SearchViewController *searchController = [[SearchViewController alloc] initWithTickerType:self.tickerType];

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:searchController];
    navController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [Flurry logAllPageViews:navController];
    
    [self.navigationController presentViewController:navController animated:YES completion:nil];
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
    NSMutableArray *array = [@[] mutableCopy];
    if (self.tickerType == HGTickerTypeMyIndexes) {
        array = IsEmpty(userInfo[HGTickerTypeMyIndexesKey]) ? @[] : userInfo[HGTickerTypeMyIndexesKey];
    } else if (self.tickerType == HGTickerTypeMyWatchlist) {
        array = IsEmpty(userInfo[HGTickerTypeMyWatchlistKey]) ? @[] : userInfo[HGTickerTypeMyWatchlistKey];
    } else if (self.tickerType == HGTickerTypeMyPositions) {
        array = IsEmpty(userInfo[HGTickerTypeMyPositionsKey]) ? @[] : userInfo[HGTickerTypeMyPositionsKey];
    }
    
    self.dataSource = [[NSMutableArray alloc] initWithArray:array];
    
    [self.tableView reloadData];
}

- (void)positionSaved:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSString *tickerKey = userInfo[@"ticker_key"];
    HGTicker *ticker = userInfo[@"ticker"];
    
    if (tickerKey && ticker) {
        if ([tickerKey isEqualToString:[MercuryData keyForTickerType:self.tickerType]]) {
            self.dataSource = [NSMutableArray arrayWithArray:[[MercuryData sharedData] arrayForTickerType:self.tickerType]];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
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

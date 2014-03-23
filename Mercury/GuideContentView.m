//
//  GuideContentView.m
//  Mercury
//
//  Created by Axel Rivera on 3/22/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "GuideContentView.h"

#import <UIView+AutoLayout.h>
#import "UIViewController+Layout.h"
#import "GuideViewCell.h"
#import "UIImage+Tint.h"

static CGFloat kActionButtonHeight = 44.0;

static NSString *CellIdentifier = @"CellIdentifier";

@interface GuideContentView () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic, readwrite) NSArray *cellViews;

- (void)updateCurrentPage:(NSInteger)page;

@end

@implementation GuideContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithCellViews:@[] frame:frame];
}

- (instancetype)initWithCellViews:(NSArray *)cellViews frame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        self.backgroundColor = [UIColor hg_highlightColor];

        if (IsEmpty(cellViews)) {
            cellViews = @[];
        }

        _cellViews = cellViews;

        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _flowLayout.minimumInteritemSpacing = 0.0;
        _flowLayout.minimumLineSpacing = 0.0;

        _collectionView = [[UICollectionView alloc] initWithFrame:self.frame collectionViewLayout:self.flowLayout];
        _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.pagingEnabled = YES;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;

        [_collectionView registerClass:[GuideViewCell class] forCellWithReuseIdentifier:CellIdentifier];

        [self addSubview:_collectionView];

        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectZero];
        _pageControl.translatesAutoresizingMaskIntoConstraints = NO;
        _pageControl.defersCurrentPageDisplay = YES;
        _pageControl.numberOfPages = [_cellViews count];

        [_pageControl addTarget:self
                         action:@selector(showPanelAtPageControl:)
               forControlEvents:UIControlEventValueChanged];

        [self addSubview:_pageControl];

        _actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _actionButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_actionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_actionButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.2] forState:UIControlStateHighlighted];
        [_actionButton setBackgroundImage:[UIImage backgroundTintedImageWithColor:[UIColor colorWithWhite:1.0 alpha:0.3]]
                                 forState:UIControlStateNormal];

        DLog(@"Did End Displaying Cell");
        if ([_cellViews count] == 0 || [self.cellViews count] == 1) {
            [_actionButton setTitle:@"Finish" forState:UIControlStateNormal];
        }

        [_actionButton addTarget:self action:@selector(nextAction:) forControlEvents:UIControlEventTouchUpInside];

        [_actionButton autoSetDimension:ALDimensionHeight toSize:kActionButtonHeight];
        
        [self addSubview:_actionButton];

        [self updateCurrentPage:0];
    }
    return self;
}

- (void)updateConstraints
{
    if (self.doneButton) {
        [self.doneButton autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:20.0];
        [self.doneButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:20.0];
    }

    [self.actionButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0.0];
    [self.actionButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0.0];
    [self.actionButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0.0];

    [self.collectionView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0.0, 0.0, kActionButtonHeight, 0.0)];

    [self.pageControl autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kActionButtonHeight];
    [self.pageControl autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0.0];
    [self.pageControl autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0.0];

    [self.flowLayout invalidateLayout];

    [super updateConstraints];
}

#pragma mark - Public Methods

- (void)setSkipBlock:(GuideContainerViewCompletionBlock)skipBlock
{
    _skipBlock = [skipBlock copy];

    if (_doneButton == nil) {
        _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _doneButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_doneButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.2] forState:UIControlStateHighlighted];
        [_doneButton setBackgroundImage:[UIImage backgroundTintedImageWithColor:[UIColor colorWithWhite:1.0 alpha:0.3]]
                               forState:UIControlStateNormal];

        _doneButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
        [_doneButton setTitle:@"Done" forState:UIControlStateNormal];
        _doneButton.contentEdgeInsets = UIEdgeInsetsMake(5.0, 10.0, 5.0, 10.0);

        [_doneButton sizeToFit];

        [_doneButton addTarget:self action:@selector(doneAction:) forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:_doneButton];

        [self setNeedsLayout];
    }
}

#pragma mark - Private Methods

- (void)updateCurrentPage:(NSInteger)page
{
    NSString *actionStr = @"Finish";
    if ([self.cellViews count] == 0) {
        actionStr = @"Finish";
    } else {
        if (page >= 0 && page < [self.cellViews count]) {
            GuideView *view = self.cellViews[page];
            if (view.actionString) {
                actionStr = view.actionString;
            } else {
                actionStr = @"Next";
            }
        }
    }

    [self.actionButton setTitle:actionStr forState:UIControlStateNormal];
    self.pageControl.currentPage = page;
}

#pragma mark - Selector Methods

- (void)showPanelAtPageControl:(UIPageControl *)pageControl
{
    [self.pageControl setCurrentPage:pageControl.currentPage];
}

- (void)nextAction:(id)sender
{
    NSInteger currentPage = self.pageControl.currentPage;
    NSInteger nextPage = currentPage + 1;
    if (nextPage < [self.cellViews count]) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:nextPage inSection:0]
                                    atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                            animated:YES];
        [self updateCurrentPage:nextPage];
    } else {
        if (self.completionBlock) {
            self.completionBlock();
        }
    }
}

- (void)doneAction:(id)sender
{
    if (self.skipBlock) {
        self.skipBlock();
    }
}

#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.cellViews count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GuideViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[GuideViewCell alloc] initWithFrame:CGRectMake(0.0,
                                                               0.0,
                                                               self.bounds.size.width,
                                                               self.bounds.size.height - kActionButtonHeight)];
    }

    GuideView *view = self.cellViews[indexPath.row];
    cell.guideView = view;

    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout Methods

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return collectionView.frame.size;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeZero;
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageMetric = 0.0;
    CGFloat contentOffset = 0.0;

    pageMetric = scrollView.frame.size.width;
    contentOffset = scrollView.contentOffset.x;

    NSInteger page = floor((contentOffset - pageMetric / 2.0) / pageMetric) + 1;
    [self updateCurrentPage:page];
}

@end

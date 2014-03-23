//
//  GuideContentView.h
//  Mercury
//
//  Created by Axel Rivera on 3/22/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^GuideContainerViewCompletionBlock)(void);

@interface GuideContentView : UIView

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) UIButton *doneButton;
@property (strong, nonatomic) UIButton *actionButton;

@property (strong, nonatomic, readonly) NSArray *cellViews;

@property (copy, nonatomic) GuideContainerViewCompletionBlock completionBlock;
@property (copy, nonatomic) GuideContainerViewCompletionBlock skipBlock;

- (instancetype)initWithCellViews:(NSArray *)cellViews frame:(CGRect)frame;

@end

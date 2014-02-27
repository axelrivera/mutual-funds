//
//  PositionDetailViewController.h
//  Mercury
//
//  Created by Axel Rivera on 2/22/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NCISimpleChartView;

typedef void(^PositionDetailViewControllerSaveBlock)(HGTicker *ticker);

@interface PositionDetailViewController : UITableViewController

@property (strong, nonatomic) NCISimpleChartView *chartView;

@property (strong, nonatomic) HGTicker *ticker;
@property (strong, nonatomic) NSArray *dataSource;
@property (strong, nonatomic) NSArray *chartDataSource;
@property (assign, nonatomic) BOOL allowSave;
@property (copy, nonatomic) PositionDetailViewControllerSaveBlock saveBlock;

- (instancetype)initWithTicker:(HGTicker *)ticker;
- (instancetype)initWithTicker:(HGTicker *)ticker allowSave:(BOOL)allowSave;

@end

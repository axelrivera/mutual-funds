//
//  PositionDetailViewController.h
//  Mercury
//
//  Created by Axel Rivera on 2/22/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LCLineChartView;

typedef void(^PositionDetailViewControllerSaveBlock)(HGTicker *ticker);

@interface PositionDetailViewController : UIViewController

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) LCLineChartView *chartView;

@property (strong, nonatomic) HGTicker *ticker;
@property (strong, nonatomic) NSArray *dataSource;
@property (strong, nonatomic) NSArray *chartSignals;
@property (strong, nonatomic) NSDate *chartSignalStartDate;
@property (strong, nonatomic) NSDate *chartSignalEndDate;
@property (strong, nonatomic) NSString *currentSignal;
@property (strong, nonatomic) NSDate *currentSignalDate;
@property (assign, nonatomic) BOOL allowSave;
@property (copy, nonatomic) PositionDetailViewControllerSaveBlock saveBlock;
@property (strong, nonatomic) NSString *chartRange;

@property (assign, nonatomic) NSInteger currentIndex;

- (instancetype)initWithTicker:(HGTicker *)ticker;
- (instancetype)initWithTicker:(HGTicker *)ticker allowSave:(BOOL)allowSave;

@end

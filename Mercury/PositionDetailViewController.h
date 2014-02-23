//
//  PositionDetailViewController.h
//  Mercury
//
//  Created by Axel Rivera on 2/22/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NCISimpleChartView;

@interface PositionDetailViewController : UITableViewController

@property (strong, nonatomic) NCISimpleChartView *chartView;

@property (strong, nonatomic) HGPosition *position;
@property (strong, nonatomic) NSArray *chartDataSource;

- (instancetype)initWithPosition:(HGPosition *)position;

@end

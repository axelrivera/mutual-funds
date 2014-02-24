//
//  PositionChartViewController.h
//  Mercury
//
//  Created by Axel Rivera on 2/22/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NCISimpleChartView;

@interface PositionChartViewController : UIViewController

@property (strong, nonatomic) NCISimpleChartView *chartView;

@property (strong, nonatomic) HGTicker *ticker;
@property (strong, nonatomic) NSArray *dataSource;

- (instancetype)initWithTicker:(HGTicker *)ticker;

@end

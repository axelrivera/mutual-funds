//
//  PositionChartViewController.h
//  Mercury
//
//  Created by Axel Rivera on 2/22/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LCLineChartView;

@interface PositionChartViewController : UIViewController

@property (strong, nonatomic) LCLineChartView *chartView;

@property (strong, nonatomic) UIView *footerView;
@property (strong, nonatomic) UISegmentedControl *segmentedControl;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *dateLabel;

@property (strong, nonatomic) HGTicker *ticker;

@property (copy, nonatomic) HGCompletionBlock completionBlock;

- (instancetype)initWithTicker:(HGTicker *)ticker;

@end

//
//  SettingsViewController.h
//  Mercury
//
//  Created by Axel Rivera on 2/22/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UITableViewController

@property (strong, nonatomic) UISegmentedControl *detailChartSegmentedControl;
@property (strong, nonatomic) UISegmentedControl *fullscreenChartSegmentedControl;

@property (strong, nonatomic) NSArray *dataSource;
@property (strong, nonatomic) NSString *currentDetailChartRange;
@property (strong, nonatomic) NSString *currentFullscreenChartRange;

@end

//
//  WatchlistViewController.h
//  Mercury
//
//  Created by Axel Rivera on 2/21/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PositionsViewController : UIViewController

@property (assign, nonatomic) HGTickerType tickerType;

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *dataSource;

- (instancetype)initWithTickerType:(HGTickerType)tickerType;

@end

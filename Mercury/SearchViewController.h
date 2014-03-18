//
//  SearchViewController.h
//  Mercury
//
//  Created by Axel Rivera on 3/4/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PositionsViewController;

@interface SearchViewController : UITableViewController

@property (assign, nonatomic) HGTickerType tickerType;
@property (strong, nonatomic) NSArray *searchDataSource;
@property (strong, nonatomic) NSArray *dataSource;

- (instancetype)initWithTickerType:(HGTickerType)tickerType;

@end

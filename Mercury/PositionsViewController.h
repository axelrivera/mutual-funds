//
//  WatchlistViewController.h
//  Mercury
//
//  Created by Axel Rivera on 2/21/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, HGPositionType) {
    HGPositionTypeWatchlist,
    HGPositionTypeMyPositions
};

@interface PositionsViewController : UIViewController

@property (assign, nonatomic) HGPositionType positionType;

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *dataSource;

- (instancetype)initWithPositionType:(HGPositionType)positionType;

@end

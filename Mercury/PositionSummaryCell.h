//
//  PositionSummaryCell.h
//  Mercury
//
//  Created by Axel Rivera on 2/22/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PositionSummaryCell : UITableViewCell

@property (strong, nonatomic) UILabel *symbolLabel;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *closeLabel;
@property (strong, nonatomic) UILabel *changeLabel;
@property (strong, nonatomic) UILabel *dateLabel;

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end

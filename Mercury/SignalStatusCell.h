//
//  SignalStatusCell.h
//  Mercury
//
//  Created by Axel Rivera on 3/2/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignalStatusCell : UITableViewCell

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *descriptionLabel;

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end

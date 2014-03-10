//
//  SearchCell.h
//  Mercury
//
//  Created by Axel Rivera on 3/9/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchCell : UITableViewCell

@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *symbolLabel;
@property (strong, nonatomic) UILabel *typeLabel;

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end

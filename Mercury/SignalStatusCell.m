//
//  SignalStatusCell.m
//  Mercury
//
//  Created by Axel Rivera on 3/2/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "SignalStatusCell.h"

#import <UIView+AutoLayout.h>

@implementation SignalStatusCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.opaque = YES;
        self.textLabel.hidden = YES;
        self.detailTextLabel.hidden = YES;
        self.imageView.hidden = YES;
        
        self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.font = [UIFont systemFontOfSize:24.0];
        _titleLabel.textColor = [UIColor hg_textColor];
        _titleLabel.highlightedTextColor = [UIColor whiteColor];
        _titleLabel.backgroundColor = [UIColor clearColor];
        
        [_titleLabel autoSetDimension:ALDimensionHeight toSize:28.0];
        
        _descriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _descriptionLabel.font = [UIFont systemFontOfSize:12.0];
        _descriptionLabel.textColor = [UIColor hg_textColor];
        _descriptionLabel.highlightedTextColor = [UIColor whiteColor];
        _descriptionLabel.backgroundColor = [UIColor clearColor];
        _descriptionLabel.numberOfLines = 3;
        
        [_descriptionLabel autoSetDimension:ALDimensionHeight toSize:44.0];
        
        [self.contentView addSubview:_titleLabel];
        [self.contentView addSubview:_descriptionLabel];
    }
    return self;
}

- (void)updateConstraints
{
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:10.0];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10.0];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10.0];
    
    [self.descriptionLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:10.0];
    [self.descriptionLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10.0];
    [self.descriptionLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10.0];
    
    [super updateConstraints];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

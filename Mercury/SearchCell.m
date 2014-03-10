//
//  SearchCell.m
//  Mercury
//
//  Created by Axel Rivera on 3/9/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "SearchCell.h"

#import <UIView+AutoLayout.h>

@implementation SearchCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.opaque = YES;
        self.textLabel.hidden = YES;
        self.detailTextLabel.hidden = YES;
        self.imageView.hidden = YES;
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _nameLabel.font = [UIFont systemFontOfSize:14.0];
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.highlightedTextColor = [UIColor whiteColor];
        _nameLabel.backgroundColor = [UIColor clearColor];
        
        _symbolLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _symbolLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _symbolLabel.font = [UIFont systemFontOfSize:12.0];
        _symbolLabel.textColor = [UIColor grayColor];
        _symbolLabel.highlightedTextColor = [UIColor whiteColor];
        _symbolLabel.backgroundColor = [UIColor clearColor];
        
        _typeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _typeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _typeLabel.font = [UIFont systemFontOfSize:12.0];
        _typeLabel.textColor = [UIColor grayColor];
        _typeLabel.highlightedTextColor = [UIColor whiteColor];
        _typeLabel.backgroundColor = [UIColor clearColor];
        _typeLabel.textAlignment = NSTextAlignmentRight;
        
        [self.contentView addSubview:_nameLabel];
        [self.contentView addSubview:_symbolLabel];
        [self.contentView addSubview:_typeLabel];
        
    }
    return self;
}

- (void)updateConstraints
{
    [self.nameLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:10.0];
    [self.nameLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:15.0];
    [self.nameLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0.0];
    
    [self.symbolLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:10.0];
    [self.symbolLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:15.0];
    
    [self.typeLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:10.0];
    [self.typeLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0.0];
    
    [self.symbolLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.typeLabel withOffset:5.0];
    
    [super updateConstraints];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

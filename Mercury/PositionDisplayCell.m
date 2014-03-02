//
//  DisplayCell.m
//  Mercury
//
//  Created by Axel Rivera on 2/21/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "PositionDisplayCell.h"

#import <UIView+AutoLayout.h>

#define kIndicatorViewWidth 10.0

@interface PositionDisplayCell ()

@end

@implementation PositionDisplayCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.opaque = NO;
        self.textLabel.hidden = YES;
        self.detailTextLabel.hidden = YES;
        self.imageView.hidden = YES;
        
        self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
        
        _symbolLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _symbolLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _symbolLabel.font = [UIFont systemFontOfSize:26.0];
        _symbolLabel.textColor = [UIColor hg_textColor];
        _symbolLabel.highlightedTextColor = [UIColor whiteColor];
        _symbolLabel.backgroundColor = [UIColor clearColor];
        
        _closeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _closeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _closeLabel.font = [UIFont systemFontOfSize:26.0];
        _closeLabel.textColor = [UIColor hg_textColor];
        _closeLabel.highlightedTextColor = [UIColor whiteColor];
        _closeLabel.backgroundColor = [UIColor clearColor];
        _closeLabel.textAlignment = NSTextAlignmentRight;
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _nameLabel.font = [UIFont systemFontOfSize:12.0];
        _nameLabel.textColor = [UIColor grayColor];
        _nameLabel.highlightedTextColor = [UIColor whiteColor];
        _nameLabel.backgroundColor = [UIColor clearColor];
        
        _changeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _changeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _changeLabel.font = [UIFont systemFontOfSize:16.0];
        _changeLabel.textColor = [UIColor hg_textColor];
        _changeLabel.highlightedTextColor = [UIColor whiteColor];
        _changeLabel.backgroundColor = [UIColor clearColor];
        _changeLabel.textAlignment = NSTextAlignmentRight;
        
        [self.contentView addSubview:_symbolLabel];
        [self.contentView addSubview:_closeLabel];
        [self.contentView addSubview:_nameLabel];
        [self.contentView addSubview:_changeLabel];
    }
    return self;
}

- (void)updateConstraints
{
    [self.symbolLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:10.0];
    [self.symbolLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10.0];
    
    [self.nameLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:10.0];
    [self.nameLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10.0];
    
    [self.closeLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:10.0];
    [self.closeLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10.0];
    
    [self.changeLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10.0];
    [self.changeLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:10.0];
    
    [self.closeLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.symbolLabel withOffset:2.0];
    [self.nameLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.changeLabel withOffset:-2.0];
    
    [super updateConstraints];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

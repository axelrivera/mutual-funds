//
//  PositionSummaryCell.m
//  Mercury
//
//  Created by Axel Rivera on 2/22/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "PositionSummaryCell.h"

#import <UIView+AutoLayout.h>

#define kTextContentViewHeight 106.0

@interface PositionSummaryCell ()

@property (strong, nonatomic) UIView *textContentView;

@end

@implementation PositionSummaryCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.opaque = NO;
        self.textLabel.hidden = YES;
        self.detailTextLabel.hidden = YES;
        self.imageView.hidden = YES;
        
        self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _textContentView = [[UIView alloc] initWithFrame:CGRectZero];
        _textContentView.translatesAutoresizingMaskIntoConstraints = NO;
        _textContentView.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:_textContentView];
        
        [_textContentView autoSetDimension:ALDimensionHeight toSize:kTextContentViewHeight];
        
        _symbolLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _symbolLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _symbolLabel.font = [UIFont systemFontOfSize:26.0];
        _symbolLabel.textColor = [UIColor hg_textColor];
        _symbolLabel.highlightedTextColor = [UIColor whiteColor];
        _symbolLabel.backgroundColor = [UIColor clearColor];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _nameLabel.font = [UIFont systemFontOfSize:12.0];
        _nameLabel.textColor = [UIColor grayColor];
        _nameLabel.highlightedTextColor = [UIColor whiteColor];
        _nameLabel.backgroundColor = [UIColor clearColor];
        
        _closeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _closeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _closeLabel.font = [UIFont systemFontOfSize:48.0];
        _closeLabel.textColor = [UIColor hg_textColor];
        _closeLabel.highlightedTextColor = [UIColor whiteColor];
        _closeLabel.backgroundColor = [UIColor clearColor];
        
        _changeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _changeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _changeLabel.font = [UIFont systemFontOfSize:14.0];
        _changeLabel.textColor = [UIColor hg_textColor];
        _changeLabel.highlightedTextColor = [UIColor whiteColor];
        _changeLabel.backgroundColor = [UIColor clearColor];
        
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _dateLabel.font = [UIFont systemFontOfSize:10.0];
        _dateLabel.textColor = [UIColor grayColor];
        _dateLabel.highlightedTextColor = [UIColor whiteColor];
        _dateLabel.backgroundColor = [UIColor clearColor];
        
        [_textContentView addSubview:_symbolLabel];
        [_textContentView addSubview:_closeLabel];
        [_textContentView addSubview:_nameLabel];
        [_textContentView addSubview:_changeLabel];
        [_textContentView addSubview:_dateLabel];
    }
    return self;
}

- (void)updateConstraints
{
    [self.textContentView autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [self.textContentView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10.0];
    [self.textContentView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10.0];
    
    [self.symbolLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0.0];
    [self.symbolLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0.0];
    
    CGSize symbolSize = [self.symbolLabel.text hg_sizeWithFont:self.symbolLabel.font
                                                      forWidth:(self.bounds.size.width - 20.0) / 2.0
                                                 lineBreakMode:NSLineBreakByTruncatingTail];
    
    [self.symbolLabel autoSetDimension:ALDimensionWidth toSize:symbolSize.width];
    
    [self.nameLabel autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.symbolLabel withOffset:-3.0];
    [self.nameLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0.0];
    
    [self.symbolLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.nameLabel withOffset:-5.0];
    
    [self.closeLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.symbolLabel];
    [self.closeLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0.0];
    [self.closeLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0.0];
    
    [self.changeLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.closeLabel];
    [self.changeLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0.0];
    
    [self.dateLabel autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.changeLabel];
    [self.dateLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.changeLabel withOffset:3.0];
    
    [super updateConstraints];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

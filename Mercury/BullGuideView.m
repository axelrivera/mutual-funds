//
//  BullGuideView.m
//  Mercury
//
//  Created by Axel Rivera on 3/23/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "BullGuideView.h"

@implementation BullGuideView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel.text = @"BULLISH MARKET";

        self.textLabel1.text =
        @"The 200-day moving average is a popular, quantified, long-term trend indicator. "
        "Markets trading above the 200-day moving average tend to be in longer term uptrends.";

        [self setImage:[UIImage imageNamed:@"bullish_signal"]];
    }
    return self;
}

- (void)updateConstraints
{
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:60.0];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:15.0];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:15.0];

    [self.imageView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.titleLabel withOffset:20.0];
    [self.imageView autoAlignAxisToSuperviewAxis:ALAxisVertical];

    [self.textLabel1 autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.imageView withOffset:20.0];
    [self.textLabel1 autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.titleLabel];
    [self.textLabel1 autoAlignAxis:ALAxisVertical toSameAxisOfView:self.titleLabel];

    [super updateConstraints];
}

@end

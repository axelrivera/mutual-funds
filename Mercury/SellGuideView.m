//
//  SellGuideView.m
//  Mercury
//
//  Created by Axel Rivera on 3/23/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "SellGuideView.h"

@implementation SellGuideView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel.text = @"SELL SIGNAL";

        self.textLabel1.text =
        @"A SELL signal is generated when the 50-day moving average closes BELOW the 200-day moving average.";

        [self setImage:[UIImage imageNamed:@"sell_signal"]];
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

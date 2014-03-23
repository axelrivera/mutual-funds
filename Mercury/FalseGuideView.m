//
//  FalseGuideView.m
//  Mercury
//
//  Created by Axel Rivera on 3/23/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "FalseGuideView.h"

@implementation FalseGuideView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel.text = @"FALSE SIGNALS";

        self.textLabel1.text =
        @"Moving Averages don't provide accurate signals when both 50-day and 200-day are moving sideways. "
        "In such a case, you should do additional research to confirm the signal and take action.";

        [self setImage:[UIImage imageNamed:@"sideways_signal"]];

        self.actionString = @"Finish";
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

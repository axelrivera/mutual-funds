//
//  IntroGuideView.m
//  Mercury
//
//  Created by Axel Rivera on 3/22/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "IntroGuideView.h"

#import "UIImage+Tint.h"

@implementation IntroGuideView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel.text = @"MUTUAL FUND SIGNALS";

        self.textLabel1.text =
        @"This App uses Simple Moving Averages to generate BUY and SELL signals for No-Load Mutual Funds and ETFs.";

        self.textLabel2.text =
        @"It is ONLY RECOMMENDED FOR LONG TERM POSITIONS because signals are generated on average once a year.";

        self.textLabel3.text =
        @"The App does not recommend BUYING or SELLING of particular securities, but assists in making a decision. "
        "ALWAYS supplement the given signals with additional research to get optimal returns.";

        [self setImage:[UIImage tintedImageWithName:@"going-up" tintColor:[UIColor whiteColor]]];
    }
    return self;
}

- (void)updateConstraints
{
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:55.0];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:15.0];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:15.0];

    [self.textLabel1 autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.titleLabel withOffset:20.0];
    [self.textLabel1 autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.titleLabel];
    [self.textLabel1 autoAlignAxis:ALAxisVertical toSameAxisOfView:self.titleLabel];

    [self.textLabel2 autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.textLabel1 withOffset:15.0];
    [self.textLabel2 autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.titleLabel];
    [self.textLabel2 autoAlignAxis:ALAxisVertical toSameAxisOfView:self.titleLabel];

    [self.textLabel3 autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.textLabel2 withOffset:15.0];
    [self.textLabel3 autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.titleLabel];
    [self.textLabel3 autoAlignAxis:ALAxisVertical toSameAxisOfView:self.titleLabel];

    [self.imageView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:50.0];
    [self.imageView autoAlignAxis:ALAxisVertical toSameAxisOfView:self.titleLabel];

    [super updateConstraints];
}

@end

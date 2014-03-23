//
//  GuideViewCell.m
//  Mercury
//
//  Created by Axel Rivera on 3/22/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "GuideViewCell.h"

#import <UIView+AutoLayout.h>

static NSInteger kGuideViewTag = 100;

@implementation GuideViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _guideView = nil;
    }
    return self;
}

- (void)updateConstraints
{
    if (self.guideView) {
        [self.guideView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    }
    [super updateConstraints];
}

- (void)setGuideView:(GuideView *)guideView
{
    UIView *view = [self.contentView viewWithTag:kGuideViewTag];
    if (view) {
        [view removeFromSuperview];
    }
    _guideView = guideView;
    _guideView.translatesAutoresizingMaskIntoConstraints = NO;
    _guideView.tag = kGuideViewTag;
    [self.contentView addSubview:_guideView];
    [self setNeedsUpdateConstraints];
}

@end

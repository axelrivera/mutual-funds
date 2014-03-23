//
//  GuideView.m
//  Mercury
//
//  Created by Axel Rivera on 3/22/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "GuideView.h"

@interface GuideView ()

@property (strong, nonatomic, readwrite) UILabel *titleLabel;
@property (strong, nonatomic, readwrite) UIImageView *imageView;
@property (strong, nonatomic, readwrite) UILabel *textLabel1;
@property (strong, nonatomic, readwrite) UILabel *textLabel2;
@property (strong, nonatomic, readwrite) UILabel *textLabel3;

@end

@implementation GuideView

+ (instancetype)panel
{
    return [[[self class] alloc] initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];

        _actionString = @"Next";

        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.font = [UIFont systemFontOfSize:20.0];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor hg_lightYellowColor];

        [self addSubview:_titleLabel];

        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;

        [self addSubview:_imageView];

        _textLabel1 = [[UILabel alloc] initWithFrame:CGRectZero];
        _textLabel1.translatesAutoresizingMaskIntoConstraints = NO;
        _textLabel1.font = [UIFont systemFontOfSize:14.0];
        _textLabel1.backgroundColor = [UIColor clearColor];
        _textLabel1.textColor = [UIColor whiteColor];
        _textLabel1.textAlignment = NSTextAlignmentCenter;
        _textLabel1.numberOfLines = 0;

        [self addSubview:_textLabel1];

        _textLabel2 = [[UILabel alloc] initWithFrame:CGRectZero];
        _textLabel2.translatesAutoresizingMaskIntoConstraints = NO;
        _textLabel2.font = [UIFont systemFontOfSize:14.0];
        _textLabel2.backgroundColor = [UIColor clearColor];
        _textLabel2.textColor = [UIColor whiteColor];
        _textLabel2.textAlignment = NSTextAlignmentCenter;
        _textLabel2.numberOfLines = 0;

        [self addSubview:_textLabel2];

        _textLabel3 = [[UILabel alloc] initWithFrame:CGRectZero];
        _textLabel3.translatesAutoresizingMaskIntoConstraints = NO;
        _textLabel3.font = [UIFont systemFontOfSize:14.0];
        _textLabel3.backgroundColor = [UIColor clearColor];
        _textLabel3.textColor = [UIColor whiteColor];
        _textLabel3.textAlignment = NSTextAlignmentCenter;
        _textLabel3.numberOfLines = 0;

        [self addSubview:_textLabel3];

    }
    return self;
}

- (void)setImage:(UIImage *)image
{
    if (image) {
        self.imageView.image = image;
        [self.imageView sizeThatFits:image.size];
        self.imageView.hidden = NO;
    } else {
        self.imageView.image = nil;
        self.imageView.hidden = YES;
    }
    [self setNeedsLayout];
}

@end

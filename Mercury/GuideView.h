//
//  GuideView.h
//  Mercury
//
//  Created by Axel Rivera on 3/22/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <UIView+AutoLayout.h>

@interface GuideView : UIView

@property (strong, nonatomic, readonly) UILabel *titleLabel;
@property (strong, nonatomic, readonly) UIImageView *imageView;
@property (strong, nonatomic, readonly) UILabel *textLabel1;
@property (strong, nonatomic, readonly) UILabel *textLabel2;
@property (strong, nonatomic, readonly) UILabel *textLabel3;

@property (strong, nonatomic) NSString *actionString;

+ (instancetype)panel;

- (void)setImage:(UIImage *)image;

@end

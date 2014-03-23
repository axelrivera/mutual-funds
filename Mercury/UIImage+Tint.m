//
//  UIImage+Tint.m
//
//  Created by Axel Rivera on 8/9/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import "UIImage+Tint.h"

@implementation UIImage (Tint)

#pragma mark - Public methods

+ (UIImage *)tintedImageWithName:(NSString *)name tintColor:(UIColor *)tintColor
{
    UIImage *image = [UIImage imageNamed:name];
    return [image tintedImageWithColor:tintColor];
}

- (UIImage *)tintedGradientImageWithColor:(UIColor *)tintColor
{
    return [self tintedImageWithColor:tintColor blendingMode:kCGBlendModeOverlay];
}

- (UIImage *)tintedImageWithColor:(UIColor *)tintColor
{
    return [self tintedImageWithColor:tintColor blendingMode:kCGBlendModeDestinationIn];
}

+ (UIImage *)backgroundGradientImageWithColor:(UIColor *)tintColor
{
    return [[UIImage backgroundTemplateImage] tintedGradientImageWithColor:tintColor];
}

+ (UIImage *)backgroundTintedImageWithColor:(UIColor *)tintColor
{
    UIImage *image = [[UIImage backgroundTemplateImage] tintedImageWithColor:tintColor];
    return image;
}

+ (UIImage *)templateImage
{
    CGSize size = CGSizeMake(1.0, 1.0);
    UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    [[UIColor blackColor] setFill];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    UIImage *templateImage = nil;
    if ([image respondsToSelector:@selector(imageWithRenderingMode:)]) {
        templateImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    } else {
        templateImage = image;
    }
    return templateImage;
}

+ (UIImage *)backgroundTemplateImage
{
    UIImage *image = [UIImage templateImage];
    UIImage *resizableImage = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
                                                    resizingMode:UIImageResizingModeTile];
    UIImage *templateImage = nil;
    if ([resizableImage respondsToSelector:@selector(imageWithRenderingMode:)]) {
        templateImage = [resizableImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    } else {
        templateImage = resizableImage;
    }
    return templateImage;
}

#pragma mark - Private methods

- (UIImage *)tintedImageWithColor:(UIColor *)tintColor blendingMode:(CGBlendMode)blendMode
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    [tintColor setFill];
    CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
    UIRectFill(bounds);
    [self drawInRect:bounds blendMode:blendMode alpha:1.0f];

    if (blendMode != kCGBlendModeDestinationIn)
        [self drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0];

    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return tintedImage;
}

@end

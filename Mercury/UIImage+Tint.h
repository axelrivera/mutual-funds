//
//  UIImage+Tint.h
//
//  Created by Axel Rivera on 8/9/13.
//  Copyright (c) Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Tint)

+ (UIImage *)tintedImageWithName:(NSString *)name tintColor:(UIColor *)tintColor;

- (UIImage *)tintedGradientImageWithColor:(UIColor *)tintColor;
- (UIImage *)tintedImageWithColor:(UIColor *)tintColor;

+ (UIImage *)backgroundGradientImageWithColor:(UIColor *)tintColor;
+ (UIImage *)backgroundTintedImageWithColor:(UIColor *)tintColor;

+ (UIImage *)templateImage;
+ (UIImage *)backgroundTemplateImage;

@end

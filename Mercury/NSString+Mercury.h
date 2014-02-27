//
//  NSString+Mercury.h
//  Mercury
//
//  Created by Axel Rivera on 2/26/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Mercury)

- (CGSize)hg_sizeWithFont:(UIFont *)font forWidth:(CGFloat)width lineBreakMode:(NSLineBreakMode)lineBreakMode;
- (CGSize)hg_sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize lineBreakMode:(NSLineBreakMode)lineBreakMode;

@end

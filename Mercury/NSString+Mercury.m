//
//  NSString+Mercury.m
//  Mercury
//
//  Created by Axel Rivera on 2/26/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "NSString+Mercury.h"

#define kNSStringMercuryTextHeight 999.0

@implementation NSString (Mercury)

- (CGSize)hg_sizeWithFont:(UIFont *)font forWidth:(CGFloat)width lineBreakMode:(NSLineBreakMode)lineBreakMode
{
    CGSize maxSize = CGSizeMake(width, kNSStringMercuryTextHeight);
    
    NSDictionary *attributes = @{ NSFontAttributeName : font };
    
    CGRect rect = [self boundingRectWithSize:maxSize
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:attributes
                                     context:nil];
    
    return CGSizeMake(ceil(rect.size.width), ceil(rect.size.height));
}

- (CGSize)hg_sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize lineBreakMode:(NSLineBreakMode)lineBreakMode
{
        NSDictionary *attributes = @{ NSFontAttributeName : font };
        
        CGRect rect = [self boundingRectWithSize:maxSize
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:attributes
                                         context:nil];
    
    return CGSizeMake(ceil(rect.size.width), ceil(rect.size.height));
}

@end

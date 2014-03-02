//
//  UIColor+Mercury.m
//  Mercury
//
//  Created by Axel Rivera on 2/22/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "UIColor+Mercury.h"

@implementation UIColor (Mercury)

+ (UIColor *)hg_textColor
{
    return HexColor(0x2E3436);
}

+ (UIColor *)hg_highlightColor
{
    return HexColor(0x5C3566);
}

+ (UIColor *)hg_barBackgroundColor
{
    return HexColor(0xEEEEEC);
}

+ (UIColor *)hg_mainBackgroundColor
{
    return HexColor(0xE7E7E7);
}

+ (UIColor *)hg_changePositiveColor
{
    return HexColor(0x73D216);
}

+ (UIColor *)hg_changeNegativeColor
{
    return HexColor(0xCC0000);
}

+ (UIColor *)hg_changeNoneColor
{
    return HexColor(0xEDD400);
}

+ (UIColor *)hg_tableSeparatorColor
{
    return HexColor(0xC7C5CC);
}

@end

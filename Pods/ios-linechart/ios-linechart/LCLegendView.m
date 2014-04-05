//
//  LCLegendView.m
//  ios-linechart
//
//  Created by Marcel Ruegenberg on 02.08.13.
//  Copyright (c) 2013 Marcel Ruegenberg. All rights reserved.
//

#import "LCLegendView.h"
#import <CoreGraphics/CoreGraphics.h>

static void CGContextAddRoundedRect(CGContextRef c, CGRect rect, CGFloat radius) {
	if(2 * radius > rect.size.height) radius = rect.size.height / 2.0;
	if(2 * radius > rect.size.width) radius = rect.size.width / 2.0;
	CGContextAddArc(c, rect.origin.x + radius, rect.origin.y + radius, radius, M_PI, M_PI * 1.5, 0);
	CGContextAddArc(c, rect.origin.x + rect.size.width - radius, rect.origin.y + radius, radius, M_PI * 1.5, M_PI * 2, 0);
	CGContextAddArc(c, rect.origin.x + rect.size.width - radius, rect.origin.y + rect.size.height - radius, radius, M_PI * 2, M_PI * 0.5, 0);
	CGContextAddArc(c, rect.origin.x + radius, rect.origin.y + rect.size.height - radius, radius, M_PI * 0.5, M_PI, 0);
	CGContextAddLineToPoint(c, rect.origin.x, rect.origin.y + radius);
}

static void CGContextFillRoundedRect(CGContextRef c, CGRect rect, CGFloat radius) {
	CGContextBeginPath(c);
	CGContextAddRoundedRect(c, rect, radius);
	CGContextFillPath(c);
}

@implementation LCLegendView
@synthesize titlesFont=_titlesFont;

#define COLORPADDING 15
#define PADDING 5

- (void)drawRect:(CGRect)rect {
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(c, [[UIColor colorWithWhite:0.0 alpha:0.1] CGColor]);
    CGContextFillRoundedRect(c, self.bounds, 7);
    
    
    CGFloat y = 0;
    for(NSString *title in self.titles) {
        UIColor *color = [self.colors objectForKey:title];
        if(color) {
            [color setFill];
            CGContextFillEllipseInRect(c, CGRectMake(PADDING + 2, PADDING + round(y) + self.titlesFont.xHeight / 2 + 1, 6, 6));
        }
        [[UIColor whiteColor] set];
        // TODO: replace with new text APIs in iOS 7 only version
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [title drawAtPoint:CGPointMake(COLORPADDING + PADDING, y + PADDING + 1) withFont:self.titlesFont];
        [[UIColor blackColor] set];
        [title drawAtPoint:CGPointMake(COLORPADDING + PADDING, y + PADDING) withFont:self.titlesFont];
#pragma clang diagnostic pop
        y += [self.titlesFont lineHeight];
    }
}

- (UIFont *)titlesFont {
    if(_titlesFont == nil)
        _titlesFont = [UIFont boldSystemFontOfSize:10];
    return _titlesFont;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat h = [self.titlesFont lineHeight] * [self.titles count];
    CGFloat w = 0;
    for(NSString *title in self.titles) {
        // TODO: replace with new text APIs in iOS 7 only version
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        CGSize s = [title sizeWithFont:self.titlesFont];
#pragma clang diagnostic pop
        w = MAX(w, s.width);
    }
    return CGSizeMake(COLORPADDING + w + 2 * PADDING, h + 2 * PADDING);
}

@end

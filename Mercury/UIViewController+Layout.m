//
//  UIViewController+Layout
//
//  Created by Axel Rivera on 9/3/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import "UIViewController+Layout.h"

@implementation UIViewController (Layout)

- (CGFloat)topOrigin
{
    CGFloat top = 0.0;
    if ([self respondsToSelector:@selector(topLayoutGuide)]) {
        top = self.topLayoutGuide.length;
    }
    return top;
}

@end

//
//  UITabBarController+AutoRotation.m
//  Mercury
//
//  Created by Axel Rivera on 2/22/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "UITabBarController+AutoRotation.h"

@implementation UITabBarController (AutoRotation)

- (BOOL)shouldAutorotate
{
    if ([self.selectedViewController respondsToSelector:@selector(shouldAutorotate)]) {
        return [self.selectedViewController shouldAutorotate];
    } else {
        return NO;
    }
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([self.selectedViewController respondsToSelector:@selector(supportedInterfaceOrientations)]) {
        return [self.selectedViewController supportedInterfaceOrientations];
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

@end

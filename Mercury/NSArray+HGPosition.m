//
//  NSArray+HGPosition.m
//  Mercury
//
//  Created by Axel Rivera on 3/8/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "NSArray+HGPosition.h"

@implementation NSArray (HGPosition)

- (NSDecimalNumber *)positionSumOfCloses
{
    NSDecimalNumber *sum = [NSDecimalNumber zero];
    for (id object in self) {
        if ([object isKindOfClass:[HGHistory class]]) {
            HGHistory *history = object;
            sum = [sum decimalNumberByAdding:history.close];
        }
    }
    return sum;
}

@end

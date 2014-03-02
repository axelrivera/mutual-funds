//
//  NSDecimalNumber+Mercury.m
//  Mercury
//
//  Created by Axel Rivera on 2/27/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "NSDecimalNumber+Mercury.h"

@implementation NSDecimalNumber (Mercury)

- (BOOL)isEqualToDecimalNumber:(NSDecimalNumber *)number
{
	return [self isEqualToNumber:number];
}

- (BOOL)isGreaterThanDecimalNumber:(NSDecimalNumber *)number
{
	return ([self compare:number] == NSOrderedDescending) ? YES : NO;
}

- (BOOL)isLessThanDecimalNumber:(NSDecimalNumber *)number
{
	return ([self compare:number] == NSOrderedAscending) ? YES : NO;
}

- (BOOL)isGreaterThanOrEqualToDecimalNumber:(NSDecimalNumber *)number
{
	return ([self isGreaterThanDecimalNumber:number] || [self isEqualToDecimalNumber:number]) ? YES : NO;
}

- (BOOL)isLessThanOrEqualToDecimalNumber:(NSDecimalNumber *)number
{
	return ([self isLessThanDecimalNumber:number] || [self isEqualToDecimalNumber:number]) ? YES : NO;
}

@end

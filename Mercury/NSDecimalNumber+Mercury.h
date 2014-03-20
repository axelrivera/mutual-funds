//
//  NSDecimalNumber+Mercury.h
//  Mercury
//
//  Created by Axel Rivera on 2/27/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDecimalNumber (Mercury)

- (BOOL)isEqualToDecimalNumber:(NSDecimalNumber *)number;
- (BOOL)isGreaterThanDecimalNumber:(NSDecimalNumber *)number;
- (BOOL)isLessThanDecimalNumber:(NSDecimalNumber *)number;
- (BOOL)isGreaterThanOrEqualToDecimalNumber:(NSDecimalNumber *)number;
- (BOOL)isLessThanOrEqualToDecimalNumber:(NSDecimalNumber *)number;

- (BOOL)isNegativeDecimalNumber;
- (BOOL)isPositiveDecimalNumber;

@end

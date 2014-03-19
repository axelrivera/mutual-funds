//
//  NSNumberFormatter+Mercury.h
//  Mercury
//
//  Created by Axel Rivera on 2/26/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumberFormatter (Mercury)

+ (NSNumberFormatter *)hg_changeFormatter;
+ (NSNumberFormatter *)hg_numberFormatter;
+ (NSNumberFormatter *)hg_integerFormatter;

@end

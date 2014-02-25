//
//  NSString+Yahoo.h
//  Mercury
//
//  Created by Axel Rivera on 2/24/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Yahoo)

+ (NSString *)hg_quoteColumnsString;

- (NSArray *)hg_arrayOfQuoteDictionaries;
- (NSArray *)hg_arrayOfHistoricalDictionaries;

@end

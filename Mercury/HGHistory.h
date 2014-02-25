//
//  HGHistory.h
//  Mercury
//
//  Created by Axel Rivera on 2/22/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HGHistory : NSObject

@property (copy, nonatomic) NSDate *date;
@property (copy, nonatomic) NSDecimalNumber *close;
@property (copy, nonatomic) NSDecimalNumber *open;
@property (copy, nonatomic) NSDecimalNumber *high;
@property (copy, nonatomic) NSDecimalNumber *low;
@property (copy, nonatomic) NSNumber *volume;
@property (copy, nonatomic) NSDecimalNumber *adjustedClose;
@property (copy, nonatomic) NSDecimalNumber *sma1;
@property (copy, nonatomic) NSDecimalNumber *sma2;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (id)sma1Value;
- (id)sma2Value;

@end

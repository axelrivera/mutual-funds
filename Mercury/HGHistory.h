//
//  HGHistory.h
//  Mercury
//
//  Created by Axel Rivera on 2/22/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HGHistory : NSObject <NSCoding>

@property (copy, nonatomic) NSDate *date;
@property (copy, nonatomic) NSDecimalNumber *close;
@property (copy, nonatomic) NSDecimalNumber *open;
@property (copy, nonatomic) NSDecimalNumber *high;
@property (copy, nonatomic) NSDecimalNumber *low;
@property (copy, nonatomic) NSNumber *volume;
@property (copy, nonatomic) NSDecimalNumber *adjustedClose;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

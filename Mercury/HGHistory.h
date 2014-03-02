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

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (void)setCloseFromString:(NSString *)closeString;

@end

//
//  HGSMAValue.h
//  Mercury
//
//  Created by Axel Rivera on 3/8/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HGSMAValue : NSObject

@property (copy, nonatomic) NSDate *date;
@property (copy, nonatomic) NSDecimalNumber *SMA;

+ (instancetype)instanceWithDate:(NSDate *)date SMA:(NSDecimalNumber *)SMA;

@end

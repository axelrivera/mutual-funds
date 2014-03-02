//
//  NSDateFormatter+Mercury.h
//  Mercury
//
//  Created by Axel Rivera on 2/22/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateFormatter (Mercury)

+ (NSDateFormatter *)hg_monthFormatter;
+ (NSDateFormatter *)hg_dayFormatter;
+ (NSDateFormatter *)hg_yearFormatter;
+ (NSDateFormatter *)hg_shortDateFormatter;
+ (NSDateFormatter *)hg_lastTradeDateFormatter;
+ (NSDateFormatter *)hg_signalDateFormatter;

@end

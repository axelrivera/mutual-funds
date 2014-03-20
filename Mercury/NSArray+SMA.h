//
//  NSArray+SMA.h
//  Mercury
//
//  Created by Axel Rivera on 2/27/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^HGCurrentSignalBlock)(BOOL available, NSString *signal, NSArray *pastSignals);
typedef void(^HGSignalsBlock)(BOOL succeded, NSArray *history, NSArray *SMA1, NSArray *SMA2, NSArray *signals);

@interface NSArray (SMA)

- (NSArray *)SMA_arrayForPeriod:(NSUInteger)period interval:(NSUInteger)interval;

+ (void)SMA_currentSignalForHistory:(NSArray *)history SMA1:(NSArray *)SMA1 SMA2:(NSArray *)SMA2 block:(HGCurrentSignalBlock)block;
+ (void)SMA_signalsForHistory:(NSArray *)history SMA1:(NSArray *)SMA1 SMA2:(NSArray *)SMA2 block:(HGSignalsBlock)block;
+ (NSDecimalNumber *)SMA_momentumForSMA:(NSArray *)SMA;

@end

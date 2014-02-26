//
//  YahooAPIClient.h
//  Mercury
//
//  Created by Axel Rivera on 2/22/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import <AFHTTPRequestOperationManager.h>

typedef void(^HGPositionsCompletionBlock)(NSArray *positions, NSError *error);
typedef void(^HGHistoricalDataCompletionBlock)(NSString *historicalData, NSError *error);

@interface YahooAPIClient : AFHTTPRequestOperationManager

- (void)fetchPositionsForSymbols:(NSArray *)symbols completion:(HGPositionsCompletionBlock)completion;

- (void)fetchHistoricalDataForSymbol:(NSString *)symbol
                                                 start:(NSDate *)start
                                                   end:(NSDate *)end
                                                period:(NSString *)period
                                            completion:(HGHistoricalDataCompletionBlock)completion;

+ (instancetype)sharedClient;

@end

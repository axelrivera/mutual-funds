//
//  YahooAPIClient.h
//  Mercury
//
//  Created by Axel Rivera on 2/22/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import <AFHTTPSessionManager.h>

typedef void(^HGPositionsCompletionBlock)(NSArray *positions, NSError *error);
typedef void(^HGHistoricalDataCompletionBlock)(NSArray *historicalData, NSError *error);

@interface YahooAPIClient : AFHTTPSessionManager

- (NSURLSessionDataTask *)fetchPositionsForSymbols:(NSArray *)symbols completion:(HGPositionsCompletionBlock)completion;

- (NSURLSessionDataTask *)fetchHistoricalDataForSymbol:(NSString *)symbol
                                                 start:(NSDate *)start
                                                   end:(NSDate *)end
                                                period:(NSString *)period
                                            completion:(HGHistoricalDataCompletionBlock)completion;


+ (instancetype)sharedClient;

@end

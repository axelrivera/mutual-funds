//
//  YahooAPIClient.m
//  Mercury
//
//  Created by Axel Rivera on 2/22/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "YahooAPIClient.h"

#import <AFNetworkActivityIndicatorManager.h>

static NSString * const YahooAPIBaseURLString = kYahooAPIURLBaseString;

@implementation YahooAPIClient

- (instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (self) {
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    }
    return self;
}

#pragma Public Methods

- (NSURLSessionDataTask *)fetchPositionsForSymbols:(NSArray *)symbols completion:(HGPositionsCompletionBlock)completion
{
    NSDictionary *parameters = [self quoteParametersForSymbols:symbols];
    
    DLog(@"Trying to Fetch Positions With Parameters:");
    DLog(@"%@", parameters);
    
    return [self GET:@"" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        DLog(@"Fetch Response");
        DLog(@"%@", responseObject);
        
        if (!IsEmpty(responseObject[@"query"]) &&
            !IsEmpty(responseObject[@"query"][@"results"]) &&
            !IsEmpty(responseObject[@"query"][@"results"][@"row"]))
        {
            NSArray *quotesRaw = responseObject[@"query"][@"results"][@"row"];
            NSMutableArray *positions = [@[] mutableCopy];
            
            for (NSDictionary *dictionary in quotesRaw) {
                HGPosition *position = [[HGPosition alloc] initWithDictionary:dictionary];
                [positions addObject:position];
            }
            
            if (completion) {
                completion(positions, nil);
            }
        } else {
            NSError *error = [NSError errorWithDomain:@"mydomain" code:0 userInfo:nil];
            if (completion) {
                completion(nil, error);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"Fetch Error: %@", error);
        if (completion) {
            completion(nil, error);
        }
    }];
}

- (NSURLSessionDataTask *)fetchHistoricalDataForSymbol:(NSString *)symbol
                                                 start:(NSDate *)start
                                                   end:(NSDate *)end
                                                period:(NSString *)period
                                            completion:(HGHistoricalDataCompletionBlock)completion
{
    NSDictionary *parameters = [self historicalParametersForSymbol:symbol start:start end:end period:period];
    
    DLog(@"Trying to Fetch Historical Data With Parameters:");
    DLog(@"%@", parameters);
    
    return [self GET:@"" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        DLog(@"Fetch Response");
        DLog(@"%@", responseObject);
        
        if (!IsEmpty(responseObject[@"query"]) &&
            !IsEmpty(responseObject[@"query"][@"results"]) &&
            !IsEmpty(responseObject[@"query"][@"results"][@"row"]))
        {
            NSMutableArray *historyRaw = [NSMutableArray arrayWithArray:responseObject[@"query"][@"results"][@"row"]];
            
            if (!IsEmpty(historyRaw)) {
                [historyRaw removeObjectAtIndex:0];
            }
            
            NSMutableArray *history = [@[] mutableCopy];
            
            for (NSDictionary *dictionary in historyRaw) {
                HGHistory *data = [[HGHistory alloc] initWithDictionary:dictionary];
                [history addObject:data];
            }
            
            if (completion) {
                completion(history, nil);
            }
        } else {
            NSError *error = [NSError errorWithDomain:@"mydomain" code:0 userInfo:nil];
            if (completion) {
                completion(nil, error);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"Fetch Error: %@", error);
        if (completion) {
            completion(nil, error);
        }
    }];
}

#pragma mark - Private Methods

- (NSDictionary *)quoteParametersForSymbols:(NSArray *)symbols
{
    NSString *columnCodes = @"snl1c1p2d1t1xpobb6aa5mwva2";
    NSString *columns =
    @"symbol,name,close,change,change_in_percent,last_trade_date,last_trade_time,stock_exchange,"
    "previous_close,open,bid,bid_size,ask,ask_size,days_range,weeks_range_52,volume,avg_daily_volume";
    
    NSString *format = @"select * from csv where url='http://download.finance.yahoo.com/d/quotes.csv?s=%@&f=%@&e=.csv' and columns='%@'";
    NSString *query = [NSString stringWithFormat:format, [symbols componentsJoinedByString:@","], columnCodes, columns];
    
    return [self parametersForQuery:query];
}

- (NSDictionary *)historicalParametersForSymbol:(NSString *)symbol start:(NSDate *)start end:(NSDate *)end period:(NSString *)period
{
    NSString *startMonth = [[NSNumber numberWithInteger:[[[NSDateFormatter hg_monthFormatter] stringFromDate:start] integerValue] - 1] stringValue];
    NSString *startDay = [[NSDateFormatter hg_dayFormatter] stringFromDate:start];
    NSString *startYear = [[NSDateFormatter hg_yearFormatter] stringFromDate:start];
    
    NSString *endMonth = [[NSNumber numberWithInteger:[[[NSDateFormatter hg_monthFormatter] stringFromDate:end] integerValue] - 1] stringValue];
    NSString *endDay = [[NSDateFormatter hg_dayFormatter] stringFromDate:end];
    NSString *endYear = [[NSDateFormatter hg_yearFormatter] stringFromDate:end];
    
    NSString *format =
    @"select * from csv where url='http://ichart.finance.yahoo.com/table.csv?s=%@&a=%@&b=%@&c=%@&d=%@&e=%@&f=%@&g=%@'"
    " and columns='date,open,high,low,close,volume,adj_close'";
    NSString *query = [NSString stringWithFormat:format,
                       symbol, startMonth, startDay, startYear, endMonth, endDay, endYear, period];
    
    return [self parametersForQuery:query];
}

- (NSDictionary *)parametersForQuery:(NSString *)query
{
    NSMutableDictionary *dictionary = [@{ @"format" : @"json", @"ignore" : @".csv" } mutableCopy];
    if (!IsEmpty(query)) {
        dictionary[@"q"] = query;
    }
    
    return dictionary;
}

#pragma mark - Singleton Methods

+ (instancetype)sharedClient
{
    static YahooAPIClient *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[[self class] alloc] initWithBaseURL:[NSURL URLWithString:YahooAPIBaseURLString]];
    });
    return _sharedInstance;
}

@end

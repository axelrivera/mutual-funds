//
//  YahooAPIClient.m
//  Mercury
//
//  Created by Axel Rivera on 2/22/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "YahooAPIClient.h"

#import "NSString+Yahoo.h"

static NSString * const YahooAPIBaseURLString = kYahooAPIURLBaseString;

@implementation YahooAPIClient

- (instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (self) {
        self.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    return self;
}

#pragma Public Methods

- (void)fetchPositionsForSymbols:(NSArray *)symbols completion:(HGPositionsCompletionBlock)completion
{
    NSString *symbolsStr = [symbols componentsJoinedByString:@","];
    NSDictionary *parameters = @{ @"s" : symbolsStr, @"f" : [NSString hg_quoteColumnsString] };
    
    DLog(@"Trying to Fetch Positions With Parameters:");
    DLog(@"%@", parameters);
    
    [self GET:@"http://download.finance.yahoo.com/d/quotes.csv" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        DLog(@"Fetch Response");
        NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSArray *quotesRaw = [responseString hg_arrayOfQuoteDictionaries];
        DLog(@"%@", quotesRaw);
        
        NSMutableArray *positions = [@[] mutableCopy];
        
        for (NSDictionary *dictionary in quotesRaw) {
            HGPosition *position = [[HGPosition alloc] initWithDictionary:dictionary];
            [positions addObject:position];
        }
        
        DLog(@"positions: %@", positions);
        
        if (completion) {
            completion(positions, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"Fetch Error: %@", error);
        if (completion) {
            completion(nil, error);
        }
    }];
}

- (void)fetchHistoricalDataForSymbol:(NSString *)symbol
                               start:(NSDate *)start
                                 end:(NSDate *)end
                              period:(NSString *)period
                          completion:(HGHistoricalDataCompletionBlock)completion
{
    NSString *startMonth = [[NSNumber numberWithInteger:[[[NSDateFormatter hg_monthFormatter] stringFromDate:start] integerValue] - 1] stringValue];
    NSString *startDay = [[NSDateFormatter hg_dayFormatter] stringFromDate:start];
    NSString *startYear = [[NSDateFormatter hg_yearFormatter] stringFromDate:start];
    
    NSString *endMonth = [[NSNumber numberWithInteger:[[[NSDateFormatter hg_monthFormatter] stringFromDate:end] integerValue] - 1] stringValue];
    NSString *endDay = [[NSDateFormatter hg_dayFormatter] stringFromDate:end];
    NSString *endYear = [[NSDateFormatter hg_yearFormatter] stringFromDate:end];
    
    NSDictionary *parameters = @{ @"s" : symbol,
                                  @"a" : startMonth,
                                  @"b" : startDay,
                                  @"c" : startYear,
                                  @"d" : endMonth,
                                  @"e" : endDay,
                                  @"f" : endYear,
                                  @"g" : period };
    
    DLog(@"Trying to Fetch Historical Data With Parameters:");
    DLog(@"%@", parameters);
    
    [self GET:@"http://ichart.finance.yahoo.com/table.csv" parameters:parameters
      success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         DLog(@"Fetch History for %@", symbol)
         NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
         
         if (completion) {
             completion(responseString, nil);
         }
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         DLog(@"Fetch Error: %@", error);
         if (completion) {
             completion(nil, error);
         }
     }];
}

#pragma mark - Singleton Methods

+ (instancetype)sharedClient
{
    static YahooAPIClient *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[[self class] alloc] initWithBaseURL:nil];
    });
    return _sharedInstance;
}

@end
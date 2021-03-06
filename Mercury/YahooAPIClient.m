//
//  YahooAPIClient.m
//  Mercury
//
//  Created by Axel Rivera on 2/22/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "YahooAPIClient.h"

#import "NSString+Yahoo.h"

@implementation YahooAPIClient

- (instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (self) {
        self.responseSerializer = [AFHTTPResponseSerializer serializer];
        self.requestSerializer.timeoutInterval = kHGNetworkTimeout;
    }
    return self;
}

#pragma Public Methods

- (void)fetchPositionsForSymbols:(NSArray *)symbols completion:(HGPositionsDataCompletionBlock)completion
{
    NSString *symbolsStr = [symbols componentsJoinedByString:@","];
    NSDictionary *parameters = @{ @"s" : symbolsStr, @"f" : [NSString hg_quoteColumnsString] };
    
    DLog(@"Trying to Fetch Positions With Parameters:");
    DLog(@"%@", parameters);
    
    [self GET:kYahooQuotesURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        DLog(@"Fetch Positions Response:\n");
        NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        DLog(@"\n%@", responseString);
        
        if (completion) {
            completion(responseString, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"Fetch Positions Error: %@", error);
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
    
    [self GET:kYahooHistoryURL parameters:parameters
      success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         DLog(@"Fetched History for %@", symbol);
         NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
         
         //DLog(@"\n%@", responseString);
         
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

- (void)fetchTickersForString:(NSString *)string completion:(HGTickersCompletionBlock)completion
{
    if (IsEmpty(string)) {
        string = @"";
    }
    
    NSDictionary *parameters = @{ @"query" : string,
                                  @"callback" : @"YAHOO.Finance.SymbolSuggest.ssCallback" };
    
    DLog(@"Trying to Search Ticker With Parameters:");
    DLog(@"%@", parameters);
    
    [self GET:kYahooAutocompleteURL parameters:parameters
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSCharacterSet *emptySet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
          NSString *responseString = [[[NSString alloc] initWithData:responseObject
                                                           encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:emptySet];
          
          DLog(@"Response Object: %@", responseString);
          
          NSString *offensiveStr = @"YAHOO.Finance.SymbolSuggest.ssCallback(";
          
          responseString = [responseString stringByReplacingOccurrencesOfString:offensiveStr withString:@""];
          
          NSString *JSONString = [responseString substringWithRange:NSMakeRange(0, [responseString length] - 1)];
          NSData *JSONData = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
          
          NSError *JSONError = nil;
          id JSON = [NSJSONSerialization JSONObjectWithData:JSONData options:0 error:&JSONError];
          
          if (JSONError) {
              if (completion) {
                  completion(nil, JSONError);
              }
              return;
          }
          
          if ([JSON isKindOfClass:[NSDictionary class]] &&
              JSON[@"ResultSet"] &&
              JSON[@"ResultSet"][@"Result"])
          {
              NSArray *tickersRaw = JSON[@"ResultSet"][@"Result"];
              
              DLog(@"Tickers Response: %@", tickersRaw);
              
              NSMutableArray *tickers = [@[] mutableCopy];
              
              for (NSDictionary *dictionary in tickersRaw) {
                  HGTicker *ticker = [[HGTicker alloc] initWithDictionary:dictionary];
                  [tickers addObject:ticker];
              }
              
              if (completion) {
                  completion(tickers, nil);
              }
          } else {
              if (completion) {
                  NSError *error = [NSError errorWithDomain:kMercuryErrorDomain code:0 userInfo:nil];
                  completion(nil, error);
              }
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

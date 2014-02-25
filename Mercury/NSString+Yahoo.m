//
//  NSString+Yahoo.m
//  Mercury
//
//  Created by Axel Rivera on 2/24/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "NSString+Yahoo.h"

#import <CHCSVParser.h>

#define kHGNumberOfQuoteColumns 18
#define kHGNumberOfHistorialColumns 7

/*
 
 Order for Quote Columns
 
 0 - symbol - s
 1 - name - n
 2 - close - l1
 3 - change - c1
 4 - change_in_percent - p2
 5 - last_trade_date - d1
 6 - last_trade_time - t1
 7 - stock_exchange - x
 8 - previous_close - p
 9 - open - o
 10 - bid - b
 11 - bid_size - b6
 12 - ask - a
 13 - ask_size - a5
 14 - days_range - m
 15 - weeks_range_52 - w
 16 - volume - v
 17 - avg_daily_volume - a2
 
*/

/* 
 
 Order for Historical Columns
 
 0 - date
 1 - open
 2 - high
 3 - low
 4 - close
 5 - volume
 6 - adj_close
 
*/

@implementation NSString (Yahoo)

+ (NSString *)hg_quoteColumnsString
{
    return @"snl1c1p2d1t1xpobb6aa5mwva2";
}

- (NSString *)hg_strip
{
    NSCharacterSet *emptyCharacters = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    return [self stringByTrimmingCharactersInSet:emptyCharacters];
}

- (NSArray *)hg_arrayOfQuoteDictionaries
{
    NSArray *csvArray = [self CSVComponentsWithOptions:(CHCSVParserOptionsRecognizesBackslashesAsEscapes|
                                                        CHCSVParserOptionsSanitizesFields)];
    NSMutableArray *array = [@[] mutableCopy];
    for (NSArray *row in csvArray) {
        if ([row count] == kHGNumberOfQuoteColumns) {
            NSDictionary *dictionary = @{ @"symbol" : [row[0] hg_strip],
                                          @"name" : [row[1] hg_strip],
                                          @"close" : [row[2] hg_strip],
                                          @"change" : [row[3] hg_strip],
                                          @"change_in_percent" : [row[4] hg_strip],
                                          @"last_trade_date" : [row[5] hg_strip],
                                          @"last_trade_time" : [row[6] hg_strip],
                                          @"stock_exchange" : [row[7] hg_strip],
                                          @"previous_close" : [row[8] hg_strip],
                                          @"open" : [row[9] hg_strip],
                                          @"bid" : [row[10] hg_strip],
                                          @"bid_size" : [row[11] hg_strip],
                                          @"ask" : [row[12] hg_strip],
                                          @"ask_size" : [row[13] hg_strip],
                                          @"days_range" : [row[14] hg_strip],
                                          @"weeks_range_52" : [row[15] hg_strip],
                                          @"volume" : [row[16] hg_strip],
                                          @"avg_daily_volume" : [row[17] hg_strip] };
            [array addObject:dictionary];
        }
    }
    return array;
}

- (NSArray *)hg_arrayOfHistoricalDictionaries
{
    NSArray *csvArray = [self CSVComponentsWithOptions:(CHCSVParserOptionsRecognizesBackslashesAsEscapes|
                                                        CHCSVParserOptionsSanitizesFields)];
    NSMutableArray *array = [@[] mutableCopy];
    for (NSInteger i = 0; i < [csvArray count]; i++) {
        if (i == 0) {
            continue;
        }
        
        NSArray *row = csvArray[i];
        if ([row count] == kHGNumberOfHistorialColumns) {
            NSDictionary *dictionary = @{ @"date" : [row[0] hg_strip],
                                          @"open" : [row[1] hg_strip],
                                          @"high" : [row[2] hg_strip],
                                          @"low" : [row[3] hg_strip],
                                          @"close" : [row[4] hg_strip],
                                          @"volume" : [row[5] hg_strip],
                                          @"adj_close" : [row[6] hg_strip]};
            [array addObject:dictionary];
        }
    }
    return array;
}

@end

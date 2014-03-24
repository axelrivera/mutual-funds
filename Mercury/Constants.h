//
//  Constants.h
//  Mercury
//
//  Created by Axel Rivera on 2/21/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#ifdef RELEASE
    // Production Flurry API Key
    #define FLURRY_API_KEY @"PQY9W98G6DK8HSQJJKFN"
#else
    // Development Flurry API Key
    #define FLURRY_API_KEY @"6D2RMYWBGPSMR7JJNHRR"
#endif

#define kYahooQuotesURL @"http://download.finance.yahoo.com/d/quotes.csv"
//#define kYahooQuotesURL @"http://localhost:4000/quotes.csv"
//#define kYahooQuotesURL @"https://mercury-sharingan.fwd.wf/quotes.csv"

#define kYahooHistoryURL @"http://ichart.finance.yahoo.com/table.csv"
//#define kYahooHistoryURL @"http://localhost:4000/table.csv"
//#define kYahooHistoryURL @"https://mercury-sharingan.fwd.wf/table.csv"

#define kYahooAutocompleteURL @"http://autoc.finance.yahoo.com/autoc"

// Constants
#define kHGNetworkTimeout 15.0
#define kHGMaxPositions 200
#define kHGAllPositionsSearchLimit 150

// Mercury Data File
#define kMercuryDataFile @"MercuryData.data"

// Dispatch Queue Name
#define kMercuryDispatchQueue "me.axelrivera.mercury.queue"

// Error Domain
#define kMercuryErrorDomain @"me.axelrivera.mercury.error"

#define kMercuryErrorCodeMaximumPositions 1000

// Select Keys
#define kHGSelectKey @"key"
#define kHGSelectTitle @"title"

// Helper Strings

#define kHGPositionTypeFund @"Fund"
#define kHGPositionTypeETF @"ETF"
#define kHGPositionTypeIndex @"Index"

// Notifications

#define AllPositionsReloadedNotification @"HGAllPositionsReloadedNotification"
#define MyPositionsReloadedNotification @"HGMyPositionsReloadedNotification"
#define PositionSavedNotification @"HGPositionSavedNotification"

// Helper Macro Functions

#define NSStringFromBOOL(value) value ? @"YES" : @"NO"

#define rgb(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
#define rgba(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

// HEX color macro
#define HexColor(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

// HEX color macro with alpha
#define HexColorAlpha(rgbValue, a) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif

// ALog always displays output regardless of the DEBUG setting
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

static inline BOOL IsEmpty(id thing) {
    return thing == nil
    || thing == [NSNull null]
    || ([thing respondsToSelector:@selector(length)]
        && [(NSData *)thing length] == 0)
    || ([thing respondsToSelector:@selector(count)]
        && [(NSArray *)thing count] == 0);
}

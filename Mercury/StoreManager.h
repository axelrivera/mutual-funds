//
//  StoreManager.h
//  Mercury
//
//  Created by Axel Rivera on 3/20/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <StoreKit/StoreKit.h>

FOUNDATION_EXPORT NSString * const StoreManagerProductPurchasedNotification;

typedef void (^RequestProductsCompletionBlock)(BOOL success, NSArray *products);

@interface StoreManager : NSObject

- (instancetype)initWithProductIdentifiers:(NSSet *)productIdentifiers;

- (void)requestProductsWithCompletion:(RequestProductsCompletionBlock)completion;
- (void)buyProduct:(SKProduct *)product;
- (BOOL)productPurchased:(NSString *)productIdentifier;
- (void)restoreCompletedTransactions;
- (void)provideContentForProductIdentifier:(NSString *)productIdentifier;

@end

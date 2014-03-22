//
//  StoreManager.m
//  Mercury
//
//  Created by Axel Rivera on 3/20/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "StoreManager.h"

NSString * const StoreManagerProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";

@interface StoreManager () <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (strong, nonatomic) SKProductsRequest *productsRequest;
@property (copy, nonatomic) RequestProductsCompletionBlock completionBlock;
@property (strong, nonatomic) NSSet *productIdentifiers;
@property (strong, nonatomic) NSMutableSet *purchasedProductIdentifiers;

@end

@implementation StoreManager

- (instancetype)initWithProductIdentifiers:(NSSet *)productIdentifiers
{
    self = [super init];
    if (self) {
        _productIdentifiers = productIdentifiers;
        _purchasedProductIdentifiers = [NSMutableSet set];
        
        for (NSString * productIdentifier in _productIdentifiers) {
            BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
            if (productPurchased) {
                [_purchasedProductIdentifiers addObject:productIdentifier];
                DLog(@"Previously purchased: %@", productIdentifier);
            } else {
                DLog(@"Not purchased: %@", productIdentifier);
            }
        }

        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

#pragma mark - Public Methods

- (void)requestProductsWithCompletion:(RequestProductsCompletionBlock)completion
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    self.completionBlock = completion;
    
    self.productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:self.productIdentifiers];
    self.productsRequest.delegate = self;
    [self.productsRequest start];
}

- (BOOL)productPurchased:(NSString *)productIdentifier
{
    return [self.purchasedProductIdentifiers containsObject:productIdentifier];
}

- (void)buyProduct:(SKProduct *)product
{
    DLog(@"Buying %@...", product.productIdentifier);

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    SKPayment * payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)restoreCompletedTransactions
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)provideContentForProductIdentifier:(NSString *)productIdentifier
{
    [self.purchasedProductIdentifiers addObject:productIdentifier];

    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [[NSNotificationCenter defaultCenter] postNotificationName:StoreManagerProductPurchasedNotification
                                                        object:productIdentifier userInfo:nil];
}

#pragma mark - Private Methods

- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    DLog(@"completeTransaction...");

    [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    DLog(@"restoreTransaction...");

    [self provideContentForProductIdentifier:transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    DLog(@"failedTransaction...");
    if (transaction.error.code != SKErrorPaymentCancelled) {
        DLog(@"Transaction error: %@", transaction.error.localizedDescription);
    }

    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

#pragma mark - SKProductsRequestDelegate Methods

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    DLog(@"Loaded list of products...");
    self.productsRequest = nil;
    
    NSArray *skProducts = response.products;
    
    for (SKProduct * skProduct in skProducts) {
        DLog(@"Found product: %@ %@ %0.2f", skProduct.productIdentifier, skProduct.localizedTitle, skProduct.price.floatValue);
    }
    
    if (self.completionBlock) {
        self.completionBlock(YES, skProducts);
        self.completionBlock = nil;
    }
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    DLog(@"Failed to load list of products.");
    self.productsRequest = nil;
    
    if (self.completionBlock) {
        self.completionBlock(NO, nil);
        self.completionBlock = nil;
    }
}

#pragma mark - SKPaymentTransactionObserver Methods

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    for (SKPaymentTransaction * transaction in transactions) {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    };
}

@end

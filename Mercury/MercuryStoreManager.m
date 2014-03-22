//
//  MercuryStoreManager.m
//  Mercury
//
//  Created by Axel Rivera on 3/20/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "MercuryStoreManager.h"

NSString * const HGStoreAdRemovalIdentifier = @"me.axelrivera.mutualfundsignals.purchase.adremoval";

@implementation MercuryStoreManager

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static MercuryStoreManager *sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      HGStoreAdRemovalIdentifier,
                                      nil];
        sharedInstance = [[[self class] alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

- (BOOL)purchasedAdRemoval
{
    return [self productPurchased:HGStoreAdRemovalIdentifier];
}

@end

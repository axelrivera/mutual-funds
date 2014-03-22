//
//  MercuryStoreManager.h
//  Mercury
//
//  Created by Axel Rivera on 3/20/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "StoreManager.h"

FOUNDATION_EXPORT NSString * const HGStoreAdRemovalIdentifier;

@interface MercuryStoreManager : StoreManager

+ (instancetype)sharedInstance;

- (BOOL)purchasedAdRemoval;

@end

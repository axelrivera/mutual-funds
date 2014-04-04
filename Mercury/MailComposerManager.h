//
//  MailComposerManager.h
//
//  Created by Axel Rivera on 10/26/12.
//  Copyright (c) 2012 Axel Rivera. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

@protocol MailComposerManagerDelegate;

@interface MailComposerManager : NSObject

@property (weak, nonatomic) id <MailComposerManagerDelegate> delegate;

- (void)displayComposerSheetTo:(NSArray *)toRecipients
                       subject:(NSString *)subject
                          body:(NSString *)body
                        isHTML:(BOOL)isHTML
                        target:(id)target;

@end

@protocol MailComposerManagerDelegate <NSObject>

@optional

- (void)mailComposerManagerDelegateWillFinish:(MailComposerManager *)manager;

@end

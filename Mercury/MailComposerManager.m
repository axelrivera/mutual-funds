//
//  MailComposerManager.m
//
//  Created by Axel Rivera on 10/26/12.
//  Copyright (c) 2012 Axel Rivera. All rights reserved.
//

#import "MailComposerManager.h"

@interface MailComposerManager () <MFMailComposeViewControllerDelegate>

@end

@implementation MailComposerManager

- (void)displayComposerSheetTo:(NSArray *)toRecipients
                       subject:(NSString *)subject
                          body:(NSString *)body
                        isHTML:(BOOL)isHTML
                        target:(id)target
{
    if (![MFMailComposeViewController canSendMail]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Mutual Fund Signals", nil)
                                                            message:@"E-mail not available"
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }

    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    if (toRecipients) {
        [picker setToRecipients:toRecipients];
    }
    
    [picker setSubject:subject];
    [picker setMessageBody:body isHTML:isHTML];
    if ([target respondsToSelector:@selector(presentViewController:animated:completion:)]) {
        [target presentViewController:picker animated:YES completion:nil];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate Methods

// Dismisses the email composition interface when users tap Cancel or Send.
// Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    NSString *errorString = nil;
    
    BOOL showAlert = NO;
    // Notifies users about errors associated with the interface
    switch (result)  {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed:
            errorString = [NSString stringWithFormat:NSLocalizedString(@"E-mail failed: %@", @""), [error localizedDescription]];
            showAlert = YES;
            break;
        default:
            errorString = [NSString stringWithFormat:NSLocalizedString(@"E-mail was not sent: %@", @""), [error localizedDescription]];
            showAlert = YES;
            break;
    }
    
    if (showAlert == YES) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"E-mail Error", @"")
                                                        message:errorString
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                              otherButtonTitles: nil];
        [alert show];
    } else {
        if ([self.delegate respondsToSelector:@selector(mailComposerManagerDelegateWillFinish:)]) {
            [self.delegate mailComposerManagerDelegateWillFinish:self];
        } else {
            [controller.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

@end

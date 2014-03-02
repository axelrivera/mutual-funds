//
//  SelectViewController.h
//  Mercury
//
//  Created by Axel Rivera on 3/2/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SelectCompletionBlock)(NSDictionary *dictionary);

@interface SelectViewController : UITableViewController

@property (strong, nonatomic) NSString *currentKey;
@property (strong, nonatomic) NSArray *dataSource;
@property (copy, nonatomic) SelectCompletionBlock selectedBlock;

- (instancetype)initWithDataSource:(NSArray *)dataSource currentKey:(NSString *)currentKey;

@end

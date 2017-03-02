//
//  UIViewController+TableViewSignals.h
//  Wenu
//
//  Created by Ruslan Kurmakaev on 01/03/17.
//  Copyright © 2017 rkurmakaev. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TableViewVM;

@interface UIViewController (TableViewSignals)

- (void)subscribeTableView:(UITableView *)tableView toViewModel:(id <TableViewVM>)viewModel;

@end

NS_ASSUME_NONNULL_END

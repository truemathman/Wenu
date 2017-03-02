//
//  WNTableViewVM.h
//  Wenu
//
//  Created by Ruslan Kurmakaev on 01/03/17.
//  Copyright © 2017 rkurmakaev. All rights reserved.
//

#import "TableViewVM.h"

NS_ASSUME_NONNULL_BEGIN

@interface WNTableViewVM : NSObject <TableViewVM>

- (instancetype)initWithNavigationTitle:(NSString *)navigationTitle;

@end

NS_ASSUME_NONNULL_END

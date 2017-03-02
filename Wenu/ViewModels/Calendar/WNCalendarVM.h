//
//  WNCalendarVM.h
//  Wenu
//
//  Created by Ruslan Kurmakaev on 24/07/16.
//  Copyright © 2016 rkurmakaev. All rights reserved.
//

#import "WNTableViewVM.h"
#import "CalendarVM.h"

NS_ASSUME_NONNULL_BEGIN

@class WNSyncManager;

@interface WNCalendarVM : WNTableViewVM <CalendarVM, CalendarCoordinatorVM>

- (instancetype)initWithNavigationTitle:(NSString *)navigationTitle
                            syncManager:(WNSyncManager *)syncManager;

@end

NS_ASSUME_NONNULL_END

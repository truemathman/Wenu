//
//  WNAddOrEditMealVM.h
//  Wenu
//
//  Created by Ruslan Kurmakaev on 31/07/16.
//  Copyright © 2016 rkurmakaev. All rights reserved.
//

#import "WNTableViewVM.h"
#import "AddOrEditMealVM.h"

NS_ASSUME_NONNULL_BEGIN

@class WNSyncManager;

@interface WNAddOrEditMealVM : WNTableViewVM <AddOrEditMealVM, AddOrEditMealCoordinatorVM>

- (instancetype)initWithNavigationTitle:(NSString *)navigationTitle
                                 mealID:(nullable NSString *)ID
                            syncManager:(WNSyncManager *)syncManager;

@end

NS_ASSUME_NONNULL_END

//
//  WNMealsListVM.h
//  Wenu
//
//  Created by Ruslan Kurmakaev on 31/07/16.
//  Copyright © 2016 rkurmakaev. All rights reserved.
//

#import "WNTableViewVM.h"
#import "MealsListVM.h"

NS_ASSUME_NONNULL_BEGIN

@class WNSyncManager;

@interface WNMealsListVM : WNTableViewVM <MealsListVM, MealsListCoordinatorVM>

- (instancetype)initWithNavigationTitle:(NSString *)navigationTitle
                           showCategory:(nullable NSString *)categoryID
                            syncManager:(WNSyncManager *)syncManager;

@end

NS_ASSUME_NONNULL_END

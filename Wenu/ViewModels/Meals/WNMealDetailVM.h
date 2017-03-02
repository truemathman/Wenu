//
//  WNMealDetailVM.h
//  Wenu
//
//  Created by Ruslan Kurmakaev on 31/07/16.
//  Copyright © 2016 rkurmakaev. All rights reserved.
//

#import "MealDetailVM.h"

NS_ASSUME_NONNULL_BEGIN

@class WNSyncManager;

@interface WNMealDetailVM : NSObject <MealDetailVM, MealDetailCoordinatorVM>

- (instancetype)initWithNavigationTitle:(NSString *)title
                                 mealID:(NSString *)mealID
                            syncManager:(WNSyncManager *)syncManager;

@end

NS_ASSUME_NONNULL_END

//
//  WNFilterMealsVM.h
//  Wenu
//
//  Created by Ruslan Kurmakaev on 01/08/16.
//  Copyright © 2016 rkurmakaev. All rights reserved.
//

#import "WNTableViewVM.h"
#import "FilterMealsVM.h"

NS_ASSUME_NONNULL_BEGIN

@interface WNFilterMealsVM : WNTableViewVM <FilterMealsVM, FilterMealsCoordinatorVM, UIPopoverControllerDelegate>

@end

NS_ASSUME_NONNULL_END

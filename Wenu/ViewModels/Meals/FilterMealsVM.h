//
//  FilterMealsVM.h
//  Wenu
//
//  Created by Ruslan Kurmakaev on 01/03/17.
//  Copyright © 2017 rkurmakaev. All rights reserved.
//

#import "TableViewVM.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^MealsCategoryFilterCompletion)(BOOL applied, BOOL showMealsWithoutCategory, NSArray *categoryNames);

@protocol ItemWithCheckStateVM;

@protocol FilterMealsCoordinatorVM <NSObject>

@property (nonatomic, copy) MealsCategoryFilterCompletion completion;

@end


@protocol FilterMealsVM <TableViewVM>

- (id <ItemWithCheckStateVM>)categoryForIndexPath:(NSIndexPath *)indexPath;

- (void)selectAll;
- (void)deselectAll;

- (void)cancelChanges;
- (void)applyChanges;

@end

NS_ASSUME_NONNULL_END

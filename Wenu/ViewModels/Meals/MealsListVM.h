//
//  MealsListVM.h
//  Wenu
//
//  Created by Ruslan Kurmakaev on 01/03/17.
//  Copyright © 2017 rkurmakaev. All rights reserved.
//

#import "TableViewVM.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^MealsCategoryFilterCompletion)(BOOL applied, BOOL showMealsWithoutCategory, NSArray *categoryNames);

@protocol MealInfoCellVM;

@protocol MealsListCoordinatorVM <NSObject>

@property (nonatomic, copy) void(^showDetailMeal)(NSString *mealID);
@property (nonatomic, copy) void(^addNewMeal)();
@property (nonatomic, copy) void(^showFilter)(MealsCategoryFilterCompletion completion);

@end


@protocol MealsListVM <TableViewVM>

@property (nonatomic, strong) NSString *searchQuery;

- (id <MealInfoCellVM>)mealInfoForIndexPath:(NSIndexPath *)indexPath;
- (void)deleteMealAtIndexPath:(NSIndexPath *)indexPath;

- (void)goToMealDetailInfo:(NSIndexPath *)indexPath;
- (void)goToFilter;
- (void)goToAddingMeal;

@end

NS_ASSUME_NONNULL_END

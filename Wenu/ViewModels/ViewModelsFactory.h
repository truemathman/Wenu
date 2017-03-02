//
//  ViewModelsFactory.h
//  Wenu
//
//  Created by Ruslan Kurmakaev on 01/03/17.
//  Copyright © 2017 rkurmakaev. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

@protocol AddOrEditMealCoordinatorVM;
@protocol AddCategoryVM;

@protocol AddOrEditMealVM;

@protocol CalendarCoordinatorVM;
@protocol CalendarVM;

@protocol FilterMealsCoordinatorVM;
@protocol FilterMealsVM;

@protocol MealDetailCoordinatorVM;
@protocol MealDetailVM;

@protocol MealsListCoordinatorVM;
@protocol MealsListVM;

@protocol SettingsVM;

@protocol ViewModelsFactory <NSObject>

- (id <AddCategoryVM>)addCategoryVM;
- (id <AddOrEditMealVM, AddOrEditMealCoordinatorVM>)addOrEditMealVMWithID:(nullable NSString *)mealID;
- (id <CalendarVM, CalendarCoordinatorVM>)calendarVM;
- (id <FilterMealsVM, FilterMealsCoordinatorVM>)filterMealsVM;
- (id <MealDetailVM, MealDetailCoordinatorVM>)mealDetailVM:(NSString *)mealID;
- (id <MealsListVM, MealsListCoordinatorVM>)mealsListVMForCategory:(nullable NSString *)category;
- (id <SettingsVM>)settingsVM;

@end

NS_ASSUME_NONNULL_END

//
//  WNViewModelsFactory.m
//  Wenu
//
//  Created by Ruslan Kurmakaev on 01/03/17.
//  Copyright © 2017 rkurmakaev. All rights reserved.
//

#import "WNViewModelsFactory.h"

#import "WNSyncManager.h"
#import "WNHTTPSessionManager.h"

#import "WNAddCategoryVM.h"
#import "WNAddOrEditMealVM.h"
#import "WNCalendarVM.h"
#import "WNFilterMealsVM.h"
#import "WNMealDetailVM.h"
#import "WNMealsListVM.h"
#import "WNSettingsVM.h"

@interface WNViewModelsFactory ()

@property (nonatomic, strong) WNSyncManager *syncManager;

@end


@implementation WNViewModelsFactory

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        _syncManager = [WNSyncManager sharedClient];
    }
    
    return self;
}

#pragma mark - ViewModelsFactory protocol

- (id <AddCategoryVM>)addCategoryVM {
    
    return [[WNAddCategoryVM alloc] initWithNavigationTitle:@"Add category"];
}

- (id <AddOrEditMealVM, AddOrEditMealCoordinatorVM>)addOrEditMealVMWithID:(NSString *)mealID {
    
    return [[WNAddOrEditMealVM alloc] initWithNavigationTitle:@"Add meal"
                                                       mealID:mealID
                                                  syncManager:self.syncManager];
}

- (id <CalendarVM, CalendarCoordinatorVM>)calendarVM {
    
    return [[WNCalendarVM alloc] initWithNavigationTitle:@"Calendar"
                                             syncManager:self.syncManager];
}

- (id <FilterMealsVM, FilterMealsCoordinatorVM>)filterMealsVM {
    
    return [[WNFilterMealsVM alloc] initWithNavigationTitle:@"Filter"];
}

- (id <MealDetailVM, MealDetailCoordinatorVM>)mealDetailVM:(NSString *)mealID {
    
    return [[WNMealDetailVM alloc] initWithNavigationTitle:@"Detail"
                                                    mealID:mealID
                                               syncManager:self.syncManager];
}

- (id <MealsListVM, MealsListCoordinatorVM>)mealsListVMForCategory:(nullable NSString *)category {
    
    return [[WNMealsListVM alloc] initWithNavigationTitle:@"Meals"
                                             showCategory:category
                                              syncManager:self.syncManager];
}


- (id <SettingsVM>)settingsVM {
    
    return [[WNSettingsVM alloc] initWithNavigationTitle:@"Settings"
                                             syncManager:self.syncManager];
}

@end

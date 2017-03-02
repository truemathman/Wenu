//
//  BaseFlowCoordinator+DefaultTransitions.m
//  Wenu
//
//  Created by Ruslan Kurmakaev on 02/03/17.
//  Copyright © 2017 rkurmakaev. All rights reserved.
//

#import "BaseFlowCoordinator+DefaultTransitions.h"
#import "ViewModelsFactory.h"

#import "WNAddOrEditMealVC.h"
#import "AddOrEditMealVM.h"

#import "WNAddCategoryVC.h"
#import "AddCategoryVM.h"

#import "WNMealDetailVC.h"
#import "MealDetailVM.h"

@implementation BaseFlowCoordinator (DefaultTransitions)

- (void)goToAddNewMealScreen:(UINavigationController *)navigationController {
    
    WNAddOrEditMealVC *addMealVC = [WNAddOrEditMealVC new];
    id <AddOrEditMealVM, AddOrEditMealCoordinatorVM> addMealVM = [self.viewModelsFactory addOrEditMealVMWithID:nil];
    
    @weakify(self)
    [addMealVM setAddNewCategory:^{
        
        @strongify(self)
        [self goToAddNewCategoryScreen:navigationController];
    }];
    [addMealVC setViewModel:addMealVM];
    [navigationController pushViewController:addMealVC animated:YES];
}

- (void)goToAddNewCategoryScreen:(UINavigationController *)navigationController {
    
    WNAddCategoryVC *addCategoryVC = [WNAddCategoryVC new];
    id <AddCategoryVM> addCategoryVM = [self.viewModelsFactory addCategoryVM];
    [addCategoryVC setViewModel:addCategoryVM];
    [navigationController pushViewController:addCategoryVC animated:YES];
}

- (void)goToEditMealScreen:(UINavigationController *)navigationController
                    mealID:(NSString *)mealID {
    
    WNAddOrEditMealVC *editMealVC = [WNAddOrEditMealVC new];
    id <AddOrEditMealVM, AddOrEditMealCoordinatorVM> editMealVM = [self.viewModelsFactory addOrEditMealVMWithID:mealID];
    [editMealVC setViewModel:editMealVM];
    
    @weakify(self)
    [editMealVM setAddNewCategory:^{
        
        @strongify(self)
        [self goToAddNewCategoryScreen:navigationController];
    }];
    [navigationController pushViewController:editMealVC animated:YES];
}

- (void)goToShowMealDetailInfoScreen:(UINavigationController *)navigationController
                              mealID:(NSString *)mealID {
    
    WNMealDetailVC *mealDetailVC = [WNMealDetailVC new];
    id <MealDetailVM, MealDetailCoordinatorVM> mealDetailVM = [self.viewModelsFactory mealDetailVM:mealID];
    
    @weakify(self)
    [mealDetailVM setEditMeal:^(NSString * _Nonnull mealID) {
        
        @strongify(self)
        [self goToEditMealScreen:navigationController
                          mealID:mealID];
    }];
    [mealDetailVC setViewModel:mealDetailVM];
    [navigationController pushViewController:mealDetailVC animated:YES];
}

@end

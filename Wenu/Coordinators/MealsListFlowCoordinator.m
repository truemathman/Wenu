//
//  MealsListFlowCoordinator.m
//  Wenu
//
//  Created by Ruslan Kurmakaev on 01/03/17.
//  Copyright © 2017 rkurmakaev. All rights reserved.
//

#import "MealsListFlowCoordinator.h"
#import "BaseFlowCoordinator+DefaultTransitions.h"
#import "ViewModelsFactory.h"

#import "WNMealsListVC.h"
#import "MealsListVM.h"

#import "WNFilterMealsVC.h"
#import "FilterMealsVM.h"

@implementation MealsListFlowCoordinator

- (void)startWithNavigationController:(UINavigationController *)navigationController {
    
    WNMealsListVC *mealsListVC = [[WNMealsListVC alloc] initWithSearchBar:YES];
    id <MealsListVM, MealsListCoordinatorVM> mealsListVM = [self.viewModelsFactory mealsListVMForCategory:nil];
    
    @weakify(self)
    [mealsListVM setShowDetailMeal:^(NSString * _Nonnull mealID) {
       
        @strongify(self)
        [self goToShowMealDetailInfoScreen:navigationController
                                    mealID:mealID];
    }];
    
    [mealsListVM setAddNewMeal:^{
        
        @strongify(self)
        [self goToAddNewMealScreen:navigationController];
    }];
    
    [mealsListVM setShowFilter:^(MealsCategoryFilterCompletion completion){
        
        @strongify(self)
        [self goToFilterScreen:navigationController
                    completion:completion];
    }];
    
    [mealsListVC setViewModel:mealsListVM];
    [navigationController setViewControllers:@[mealsListVC]];
}

- (void)goToFilterScreen:(UINavigationController *)navigationController
              completion:(MealsCategoryFilterCompletion)completion {
    
    WNFilterMealsVC *filterVC = [WNFilterMealsVC new];
    id <FilterMealsVM, FilterMealsCoordinatorVM> filterVM = [self.viewModelsFactory filterMealsVM];
    [filterVM setCompletion:completion];
    [filterVC setViewModel:filterVM];
    filterVC.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController *popover = filterVC.popoverPresentationController;
    popover.delegate = filterVC;
    popover.barButtonItem = [navigationController topViewController].navigationItem.rightBarButtonItem;
    [[navigationController topViewController] presentViewController:filterVC animated:YES completion:nil];
}

@end

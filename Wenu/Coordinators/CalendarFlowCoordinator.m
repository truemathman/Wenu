//
//  CalendarCoordinator.m
//  Wenu
//
//  Created by Ruslan Kurmakaev on 01/03/17.
//  Copyright © 2017 rkurmakaev. All rights reserved.
//

#import "CalendarFlowCoordinator.h"
#import "ViewModelsFactory.h"

#import "WNCalendarVC.h"
#import "CalendarVM.h"

#import "BaseFlowCoordinator+DefaultTransitions.h"

@implementation CalendarFlowCoordinator

- (void)startWithNavigationController:(UINavigationController *)navigationController {
    
    WNCalendarVC *calendarVC = [WNCalendarVC new];
    id <CalendarVM, CalendarCoordinatorVM> calendarVM = [self.viewModelsFactory calendarVM];
    
    @weakify(self)
    [calendarVM setAddNewMeal:^{
        
        @strongify(self)
        [self goToAddNewMealScreen:navigationController];
    }];
    
    [calendarVM setShowDetailMeal:^(NSString * _Nonnull mealID) {
        
        @strongify(self)
        [self goToShowMealDetailInfoScreen:navigationController
                                    mealID:mealID];
    }];
    
    [calendarVC setViewModel:calendarVM];
    [navigationController setViewControllers:@[calendarVC]];
}

@end

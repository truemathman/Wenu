//
//  BaseFlowCoordinator+DefaultTransitions.h
//  Wenu
//
//  Created by Ruslan Kurmakaev on 02/03/17.
//  Copyright © 2017 rkurmakaev. All rights reserved.
//

#import "BaseFlowCoordinator.h"

NS_ASSUME_NONNULL_BEGIN

@interface BaseFlowCoordinator (DefaultTransitions)

- (void)goToAddNewMealScreen:(UINavigationController *)navigationController;
- (void)goToShowMealDetailInfoScreen:(UINavigationController *)navigationController
                              mealID:(NSString *)mealID;
- (void)goToShowMealDetailInfoScreen:(UINavigationController *)navigationController
                              mealID:(NSString *)mealID;

@end

NS_ASSUME_NONNULL_END

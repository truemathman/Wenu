//
//  AppCoordinator.h
//  Wenu
//
//  Created by Ruslan Kurmakaev on 01/03/17.
//  Copyright © 2017 rkurmakaev. All rights reserved.
//

#import "BaseFlowCoordinator.h"

NS_ASSUME_NONNULL_BEGIN

@interface AppCoordinator : BaseFlowCoordinator

- (void)startWithTabBarController:(UITabBarController *)tabBarController;

@end

NS_ASSUME_NONNULL_END

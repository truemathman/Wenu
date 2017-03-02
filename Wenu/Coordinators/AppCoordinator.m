//
//  AppCoordinator.m
//  Wenu
//
//  Created by Ruslan Kurmakaev on 01/03/17.
//  Copyright © 2017 rkurmakaev. All rights reserved.
//

#import "AppCoordinator.h"
#import "ViewModelsFactory.h"
#import "CalendarFlowCoordinator.h"
#import "MealsListFlowCoordinator.h"
#import "SettingsFlowCoordinator.h"

static NSInteger const NumberOfTabBarItems = 3;

@interface AppCoordinator ()

@property (nonatomic, strong) id <FlowCoordinator> calendarCoordinator;
@property (nonatomic, strong) id <FlowCoordinator> mealsListCoordinator;
@property (nonatomic, strong) id <FlowCoordinator> settingsCoordinator;

@end

@implementation AppCoordinator

- (void)startWithTabBarController:(UITabBarController *)tabBarController {
    
    NSAssert([[tabBarController viewControllers] count] == NumberOfTabBarItems, @"Number of tabbar items were changed.");
    
    self.calendarCoordinator = [[CalendarFlowCoordinator alloc] initWithViewModelsFactory:self.viewModelsFactory];
    [self.calendarCoordinator startWithNavigationController:[tabBarController viewControllers][0]];
    
    self.mealsListCoordinator = [[MealsListFlowCoordinator alloc] initWithViewModelsFactory:self.viewModelsFactory];
    [self.mealsListCoordinator startWithNavigationController:[tabBarController viewControllers][1]];
    
    self.settingsCoordinator = [[SettingsFlowCoordinator alloc] initWithViewModelsFactory:self.viewModelsFactory];
    [self.settingsCoordinator startWithNavigationController:[tabBarController viewControllers][2]];
}

@end

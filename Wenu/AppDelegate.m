//
//  AppDelegate.m
//  Wenu
//
//  Created by Ruslan Kurmakaev on 23/07/16.
//  Copyright © 2016 rkurmakaev. All rights reserved.
//

#import "AppDelegate.h"
#import "AppCoordinator.h"
#import "WNViewModelsFactory.h"

@interface AppDelegate () <UITabBarControllerDelegate>

@property (nonatomic, strong) AppCoordinator *appCoordinator;
@property (nonatomic, strong) id <ViewModelsFactory> viewModelsFactory;

@end

@implementation AppDelegate {
    
    NSArray *viewModels;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self configureUIAppearance];

    [MagicalRecord setupCoreDataStack];

    self.viewModelsFactory = [[WNViewModelsFactory alloc] init];
    
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    [tabBarController setDelegate:self];
    
    self.appCoordinator = [[AppCoordinator alloc] initWithViewModelsFactory:self.viewModelsFactory];
    [self.appCoordinator startWithTabBarController:tabBarController];
    
    return YES;
}

#pragma mark - Actions

- (void)configureUIAppearance {
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor mainApplicationColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [[UINavigationBar appearance] setTranslucent:NO];
    
    [[UITabBar appearance] setBarTintColor:[UIColor whiteColor]];
    [[UITabBar appearance] setTintColor:[UIColor mainApplicationColor]];
}

#pragma mark - UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        
        [(UINavigationController *)viewController popToRootViewControllerAnimated:NO];
    }
}

@end

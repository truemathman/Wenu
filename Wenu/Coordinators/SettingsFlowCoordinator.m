//
//  SettingsFlowCoordinator.m
//  Wenu
//
//  Created by Ruslan Kurmakaev on 01/03/17.
//  Copyright © 2017 rkurmakaev. All rights reserved.
//

#import "SettingsFlowCoordinator.h"
#import "ViewModelsFactory.h"
#import "WNSettingsVC.h"

@implementation SettingsFlowCoordinator

- (void)startWithNavigationController:(UINavigationController *)navigationController {
    
    WNSettingsVC *settingsVC = [WNSettingsVC new];
    [settingsVC setViewModel:[self.viewModelsFactory settingsVM]];
    [navigationController setViewControllers:@[settingsVC]];
}

@end

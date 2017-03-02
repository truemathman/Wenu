//
//  WNSettingsVC.m
//  Wenu
//
//  Created by Ruslan Kurmakaev on 24/07/16.
//  Copyright © 2016 rkurmakaev. All rights reserved.
//

#import "WNSettingsVC.h"
#import "SettingsVM.h"
#import "WNSettingCellWithSwitch.h"

@interface WNSettingsVC () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *mainTableView;

@end


@implementation WNSettingsVC

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.navigationItem setTitle:[self.viewModel navigationTitle]];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.mainTableView setDelegate:self];
    [self.mainTableView setDataSource:self];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id <SettingsItemVM> data = [self.viewModel itemForIndexPath:indexPath];

    NSString *identifier = [NSString stringWithFormat:@"SettingCellWithSwitch%li", data.type];
    WNSettingCellWithSwitch *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        
        cell = [[WNSettingCellWithSwitch alloc] initWithReusableIdentifier:identifier
                                                                withSwitch:data.type == WNSettingTypeSwitch];
    }
    
    [cell.textLabel setText:data.title];
    [cell setAction:data.action];
    
    if (data.type == WNSettingTypeSwitch) {
        
        [cell setSwitchState:[(NSNumber *)data.initialObject boolValue]];
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [self.viewModel numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.viewModel numberOfItemsInSection:section];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    id <SettingsItemVM> data = [self.viewModel itemForIndexPath:indexPath];

    if (data.type == WNSettingTypeDefault) {
        
        [self.viewModel itemForIndexPath:indexPath].action();
    }
}

@end

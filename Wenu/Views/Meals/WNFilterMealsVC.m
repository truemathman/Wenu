//
//  WNFilterMealsVC.m
//  Wenu
//
//  Created by Ruslan Kurmakaev on 01/08/16.
//  Copyright © 2016 rkurmakaev. All rights reserved.
//

#import "WNFilterMealsVC.h"
#import "WNFilterMealsVM.h"
#import "WNSwitchCell.h"
#import "WNEmptyTableViewPlaceholder.h"
#import "UIViewController+TableViewSignals.h"

@interface WNFilterMealsVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) IBOutlet UITableView *mainTableView;
@property (nonatomic, strong) IBOutlet UIButton *selectAllButton;
@property (nonatomic, strong) IBOutlet UIButton *deselectAllButton;

@end


@implementation WNFilterMealsVC

#pragma mark - UIViewController life cycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.navigationItem setTitle:[self.viewModel navigationTitle]];

    [self.selectAllButton configureDefaultFooterButton];
    [self.deselectAllButton configureDefaultFooterButton];
    
    [self subscribeTableView:self.mainTableView toViewModel:self.viewModel];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.mainTableView setDelegate:self];
    [self.mainTableView setDataSource:self];
}

#pragma mark - Selectors

- (IBAction)selectAllButtonPressed:(UIButton *)sender {
    
    [self.viewModel selectAll];
}

- (IBAction)deselectAllButtonPressed:(UIButton *)sender {
    
    [self.viewModel deselectAll];
}

- (void)done:(UIBarButtonItem *)sender {

    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    [self.viewModel applyChanges];
}

- (void)cancel:(UIBarButtonItem *)sender {

    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    [self.viewModel cancelChanges];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"SwitchCell";

    WNSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        
        cell = [[WNSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault
                                   reuseIdentifier:identifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    [cell configure:[self.viewModel categoryForIndexPath:indexPath]];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    NSInteger numberOfSections = [self.viewModel numberOfSections];
    
    if (numberOfSections == 0 || (numberOfSections == 1 & [self.viewModel numberOfItemsInSection:0] == 0)) {
        
        WNEmptyTableViewPlaceholder *tableFooter = [WNEmptyTableViewPlaceholder new];
        [tableFooter setTranslatesAutoresizingMaskIntoConstraints:YES];

        [tableFooter.label setText:@"No categories"];
        [tableFooter.button setHidden:YES];
        [tableFooter.buttonWidth setConstant:0.f];
        
        [tableFooter setFrame:tableView.bounds];
        [tableView setTableFooterView:tableFooter];
    }
    else {
        
        [tableView setTableFooterView:nil];
    }
    
    return [self.viewModel numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.viewModel numberOfItemsInSection:section];
}

#pragma mark - UIPopoverPresentationControllerDelegate

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    
    return UIModalPresentationFullScreen;
}

- (UIViewController *)presentationController:(UIPresentationController *)controller viewControllerForAdaptivePresentationStyle:(UIModalPresentationStyle)style {
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller.presentedViewController];
    
    UIBarButtonItem *btnCancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                               target:self
                                                                               action:@selector(cancel:)];
    
    UIBarButtonItem *btnDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                             target:self
                                                                             action:@selector(done:)];
    
    navigationController.topViewController.navigationItem.leftBarButtonItem = btnCancel;
    navigationController.topViewController.navigationItem.rightBarButtonItem = btnDone;
    
    return navigationController;
}

@end

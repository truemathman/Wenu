//
//  WNAddCategoryVC.m
//  Wenu
//
//  Created by Ruslan Kurmakaev on 04/08/16.
//  Copyright © 2016 rkurmakaev. All rights reserved.
//

#import "WNAddCategoryVC.h"
#import "AddCategoryVM.h"

#import "WNSwitchCell.h"
#import "UIViewController+TableViewSignals.h"

@interface WNAddCategoryVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) IBOutlet UITableView *mainTableView;
@property (nonatomic, strong) IBOutlet UITextField *nameTextField;

@end


@implementation WNAddCategoryVC

#pragma mark - UIViewController life cycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.navigationItem setTitle:[self.viewModel navigationTitle]];
    [self addBarButtons];
    
    [self subscribeTableView:self.mainTableView toViewModel:self.viewModel];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.mainTableView setDataSource:self];
    [self.mainTableView setDelegate:self];
}

#pragma mark - Selectors

- (void)cancelButtonPressed:(UIBarButtonItem *)sender {

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doneButtonPressed:(UIBarButtonItem *)sender {
    
    NSString *name = [self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([name length] == 0) {
        
        UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:@""
                                            message:@"Please, fill in category name"
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault
                                                          handler:nil]];
        [self presentViewController:alertController
                           animated:YES
                         completion:nil];
        return ;
    }
    
    [self.viewModel setCategoryName:name];
    [self.viewModel saveChanges];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Private 

- (void)addBarButtons {
    
    self.navigationItem.leftBarButtonItem =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                  target:self
                                                  action:@selector(cancelButtonPressed:)];
    
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                  target:self
                                                  action:@selector(doneButtonPressed:)];
    
    
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    if (self.nameTextField.isFirstResponder) {
        
        [self.nameTextField resignFirstResponder];
    }
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
    
    [cell configure:[self.viewModel viewModelForIndexPath:indexPath]];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return @"Choose meals of this category:";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    NSInteger numberOfSections = [self.viewModel numberOfSections];
    
    if (numberOfSections == 1 && [self.viewModel numberOfItemsInSection:0] == 0)
        numberOfSections = 0;
    
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.viewModel numberOfItemsInSection:section];
}

@end

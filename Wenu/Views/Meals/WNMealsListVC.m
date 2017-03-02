//
//  WNMealsListVC.m
//  Wenu
//
//  Created by Ruslan Kurmakaev on 24/07/16.
//  Copyright © 2016 rkurmakaev. All rights reserved.
//

#import "WNMealsListVC.h"
#import "WNMealsListVM.h"
#import "WNMealInfoCell.h"
#import "WNMealDetailVC.h"
#import "WNAddOrEditMealVC.h"
#import "WNFilterMealsVC.h"
#import "WNEmptyTableViewPlaceholder.h"

#import "UIViewController+TableViewSignals.h"

static NSString * const MealInfoCellIdentifier = @"WNMealInfoCell";

@interface WNMealsListVC () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *mainTableView;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, assign) BOOL showSearchBar;

@end

@implementation WNMealsListVC

- (instancetype)initWithSearchBar:(BOOL)showSearchBar {
    
    if (self = [super initWithNibName:@"WNMealsListVC" bundle:[NSBundle mainBundle]]) {
        
        _showSearchBar = showSearchBar;
    }
    
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.navigationItem setTitle:[self.viewModel navigationTitle]];

    if (!self.showSearchBar) {
        
        [self.searchBar removeFromSuperview];
        self.searchBar = nil;
    }
    
    [self addBarButtons];
    [self.mainTableView registerNib:[UINib nibWithNibName:MealInfoCellIdentifier bundle:nil]
             forCellReuseIdentifier:MealInfoCellIdentifier];
    
    [self subscribeTableView:self.mainTableView toViewModel:self.viewModel];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.mainTableView setDelegate:self];
    [self.mainTableView setDataSource:self];
    
    [self.searchBar setDelegate:self];
}

#pragma mark - Selectors

- (void)addNewMealButtonPressed:(UIBarButtonItem *)sender {
    
    [self.viewModel goToAddingMeal];
}

- (void)filterButtonPressed:(UIBarButtonItem *)sender {
    
    [self.viewModel goToFilter];
}

#pragma mark - Private

- (void)addBarButtons {
    
    self.navigationItem.leftBarButtonItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                      target:self
                                                      action:@selector(addNewMealButtonPressed:)];
    
    self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"filter"]
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(filterButtonPressed:)];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.viewModel goToMealDetailInfo:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 44.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 44.f;
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WNMealInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:MealInfoCellIdentifier forIndexPath:indexPath];
    [cell configure:[self.viewModel mealInfoForIndexPath:indexPath]];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    NSInteger numberOfSections = [self.viewModel numberOfSections];
    
    if (numberOfSections == 0 || (numberOfSections == 1 & [self.viewModel numberOfItemsInSection:0] == 0)) {
        
        WNEmptyTableViewPlaceholder *tableFooter = [WNEmptyTableViewPlaceholder new];
        [tableFooter setTranslatesAutoresizingMaskIntoConstraints:YES];

        [tableFooter.button addTarget:self
                               action:@selector(addNewMealButtonPressed:)
                     forControlEvents:UIControlEventTouchUpInside];
        
        [tableFooter setFrame:tableView.bounds];
        [tableView setTableFooterView:tableFooter];
    }
    else {
        
        [tableView setTableFooterView:nil];
    }
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.viewModel numberOfItemsInSection:section];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [self.viewModel deleteMealAtIndexPath:indexPath];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    if ([self.searchBar isFirstResponder])
        [self.searchBar resignFirstResponder];
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    [self.viewModel setSearchQuery:searchText];
}

@end

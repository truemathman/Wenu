//
//  WNCalendarVC.m
//  Wenu
//
//  Created by Ruslan Kurmakaev on 24/07/16.
//  Copyright © 2016 rkurmakaev. All rights reserved.
//

#import "WNCalendarVC.h"
#import "UIViewController+TableViewSignals.h"

#import "CalendarVM.h"

#import "WNEmptyTableViewPlaceholder.h"
#import "WNDayView.h"
#import "WNDatePickerWithToolbar.h"
#import "WNMealInfoCell.h"

#import "WNMealDetailVC.h"
#import "WNAddOrEditMealVC.h"

static NSString * const MealInfoCellIdentifier = @"WNMealInfoCell";

@interface WNCalendarVC () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *weekdaysContainerView;
@property (nonatomic, strong) IBOutlet UIScrollView *weekScrollView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *calendarButtonsWidth;
@property (nonatomic, strong) IBOutlet UILabel *monthYearLabel;
@property (nonatomic, strong) IBOutlet UIButton *previousWeekButton;
@property (nonatomic, strong) IBOutlet UIButton *nextWeekButton;
@property (nonatomic, strong) IBOutlet UITableView *mainTableView;

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) WNDatePickerWithToolbar *datePicker;

@property (nonatomic, strong) NSArray <UILabel *> *weekdayLabels;
@property (nonatomic, strong) NSMutableArray <WNDayView *> *dayViews;

@end

@implementation WNCalendarVC

#pragma mark - UIViewController life cycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.navigationItem setTitle:[self.viewModel navigationTitle]];
    
    [self.view setBackgroundColor:[UIColor mainApplicationColor]];

    [self configureWeekDays];
    [self addBarButtons];
    
    [self.mainTableView registerNib:[UINib nibWithNibName:MealInfoCellIdentifier bundle:nil]
             forCellReuseIdentifier:MealInfoCellIdentifier];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    [self.mainTableView addSubview:self.refreshControl];
    
    [self subscribeRacEvents];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.view layoutIfNeeded];
    [self.weekScrollView setContentOffset:CGPointMake(CGRectGetWidth(self.weekScrollView.bounds), 0.f)];
    
    [self.weekScrollView setDelegate:self];
    [self.mainTableView setDelegate:self];
    [self.mainTableView setDataSource:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [self hideDatePicker:YES];
}

#pragma mark - Selectors

- (IBAction)showPreviousWeekButtonPressed:(UIButton *)sender {
    
    if (self.weekScrollView.contentOffset.x == CGRectGetWidth(self.weekScrollView.bounds)) {
        
        [self.weekScrollView setContentOffset:CGPointMake(0.f, 0.f) animated:YES];
    }
    else {
        
        [self changeVisibleWeekIfNeeded];
    }
}

- (IBAction)showNextWeekButtonPressed:(UIButton *)sender {

    if (self.weekScrollView.contentOffset.x == CGRectGetWidth(self.weekScrollView.bounds)) {
        
        [self.weekScrollView setContentOffset:CGPointMake(2 * CGRectGetWidth(self.weekScrollView.bounds), 0.f) animated:YES];
    }
    else {
        
        [self changeVisibleWeekIfNeeded];
    }
}

- (void)selectDateButtonPressed:(UIBarButtonItem *)sender {
    
    [self hideDatePicker:NO];
    [self.datePicker setDate:[self.viewModel selectedDate] animated:YES];
}

- (void)addNewMealButtonPressed:(UIBarButtonItem *)sender {
    
    [self.viewModel goToAddingMeal];
}

#pragma mark - Private

- (void)addBarButtons {
    
    self.navigationItem.leftBarButtonItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                      target:self
                                                      action:@selector(addNewMealButtonPressed:)];
    
    self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"calendar_bar_button"]
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(selectDateButtonPressed:)];
    
    
}

- (void)subscribeRacEvents {
    
    [self subscribeTableView:self.mainTableView toViewModel:self.viewModel];
    
    @weakify(self)
    RAC(self.monthYearLabel, text) = RACObserve(self.viewModel, monthYearOfVisibleWeek);
    
    [RACObserve(self.viewModel, firstVisibleDay) subscribeNext:^(id _) {
        @strongify(self)
        
        if (self == nil)
            return ;
        
        [self configureWeekDayLabels];
    }];
    
    [self.viewModel.refreshingStarted subscribeNext:^(id _) {
        @strongify(self)
        
        if (self == nil)
            return ;
        
        [self.refreshControl beginRefreshing];
    }];
    
    [self.viewModel.refreshingFinished subscribeNext:^(id _) {
        @strongify(self)
        
        if (self == nil)
            return ;
        
        [self.refreshControl endRefreshing];
    }];
}

- (void)hideDatePicker:(BOOL)hide {
    
    if ((self.datePicker != nil && self.datePicker.hidden == hide) || (self.datePicker == nil && hide)) {
        
        return ;
    }
    
    if (!self.datePicker) {
        
        self.datePicker = [WNDatePickerWithToolbar new];
        [self.datePicker setDatePickerMode:UIDatePickerModeDate];
        [self.view addSubview:self.datePicker];
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_datePicker]|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:NSDictionaryOfVariableBindings(_datePicker)]];
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_datePicker]|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:NSDictionaryOfVariableBindings(_datePicker)]];
        
        @weakify(self)
        [self.datePicker setOnCancel:^{
            
            @strongify(self)
            [self hideDatePicker:YES];
        }];
        
        [self.datePicker setOnDateSelected:^(NSDate *date) {
            
            @strongify(self)
            [self.viewModel selectDate:date];
            [self hideDatePicker:YES];
        }];
        
        [self.view layoutIfNeeded];
    }
    
    self.datePicker.hidden = hide;
    [self.datePicker.layer WN_addPushAnimationWithDirection:hide ? kCATransitionFromBottom : kCATransitionFromTop
                                                   duration:0.3f];
}

- (void)refreshTable {
    
    [self.viewModel refreshData];
}

#pragma mark - Configuration UI

- (void)configureWeekDays {
    
    /// Configure buttons
    [self.previousWeekButton setImage:[self.previousWeekButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.previousWeekButton.imageView setTintColor:[UIColor whiteColor]];
    
    [self.nextWeekButton setImage:[self.nextWeekButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.nextWeekButton.imageView setTintColor:[UIColor whiteColor]];
    
    /// Configure weekday labels
    NSMutableArray *weekdayLabels = [[NSMutableArray alloc] init];
    
    for (UILabel *weekdayLabel in self.weekdaysContainerView.subviews) {
        
        [weekdayLabels addObject:weekdayLabel];
    }
    
    _weekdayLabels = weekdayLabels;
    
    [self configureWeekDayLabels];
    
    /// Add day views
    int dayViewWidth = (CGRectGetWidth(self.view.bounds) - self.calendarButtonsWidth.constant * 2) / 7;
    self.calendarButtonsWidth.constant = (CGRectGetWidth(self.view.bounds) - dayViewWidth * 7) / 2;
    
    UIView *prevView = nil;
    
    for (WNDayInfoVM *dayInfoVM in [self.viewModel visibleDays]) {
        
        WNDayView *dayView = [WNDayView new];
        [dayView setViewModel:dayInfoVM];
        
        @weakify(self)
        [dayView setOnTap:^{
            
            @strongify(self)
            [self.viewModel selectDate:dayInfoVM.day];
        }];
        
        [self.weekScrollView addSubview:dayView];
        
        [self.weekScrollView addConstraint:[NSLayoutConstraint constraintWithItem:dayView
                                                                        attribute:NSLayoutAttributeWidth
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.weekScrollView
                                                                        attribute:NSLayoutAttributeWidth
                                                                       multiplier:1./7.
                                                                         constant:0.f]];
        
        [self.weekScrollView addConstraint:[NSLayoutConstraint constraintWithItem:dayView
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.weekScrollView
                                                                        attribute:NSLayoutAttributeHeight
                                                                       multiplier:1.f
                                                                         constant:0.f]];
        
        [self.weekScrollView addConstraint:[NSLayoutConstraint constraintWithItem:dayView
                                                                        attribute:NSLayoutAttributeCenterY
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.weekScrollView
                                                                        attribute:NSLayoutAttributeCenterY
                                                                       multiplier:1.f
                                                                         constant:0.f]];
        
        BOOL doesPrevViewExist = prevView != nil;
        
        [self.weekScrollView addConstraint:[NSLayoutConstraint constraintWithItem:doesPrevViewExist ? prevView : self.weekScrollView
                                                                        attribute:doesPrevViewExist ? NSLayoutAttributeTrailing : NSLayoutAttributeLeading
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:dayView
                                                                        attribute:NSLayoutAttributeLeading
                                                                       multiplier:1.f
                                                                         constant:0.f]];
        
        [self.dayViews addObject:dayView];
        prevView = dayView;
    }
    
    [self.weekScrollView addConstraint:[NSLayoutConstraint constraintWithItem:prevView
                                                                    attribute:NSLayoutAttributeTrailing
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.weekScrollView
                                                                    attribute:NSLayoutAttributeTrailing
                                                                   multiplier:1.f
                                                                     constant:0.f]];
}

- (void)configureWeekDayLabels {
    
    for (NSInteger i = 0; i < [self.weekdayLabels count]; ++i) {
        
        [(UILabel *)self.weekdayLabels[i] setText:[self.viewModel weekdaySymbol:i]];
    }
}

- (void)changeVisibleWeekIfNeeded {
    
    if (self.weekScrollView.contentOffset.x < CGRectGetWidth(self.weekScrollView.bounds)) {
        
        [self.viewModel showPreviousWeekend];
        [self.weekScrollView setContentOffset:CGPointMake(self.weekScrollView.contentOffset.x + CGRectGetWidth(self.weekScrollView.bounds), 0.f)];
    }
    else if (self.weekScrollView.contentOffset.x > CGRectGetWidth(self.weekScrollView.bounds)) {
        
        [self.viewModel showNextWeekend];
        [self.weekScrollView setContentOffset:CGPointMake(self.weekScrollView.contentOffset.x - CGRectGetWidth(self.weekScrollView.bounds), 0.f)];
    }
}

#pragma mark - UIScrollView

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if ([scrollView isEqual:self.weekScrollView]) {
        
        [self changeVisibleWeekIfNeeded];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
    if ([scrollView isEqual:self.weekScrollView]) {

        [self changeVisibleWeekIfNeeded];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    if ([scrollView isEqual:self.mainTableView]) {
        
        [self hideDatePicker:YES];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.viewModel goToMealDetailInfo:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [(WNMealInfoCell *)cell configure:[self.viewModel mealInfoForIndexPath:indexPath]];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 44;
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WNMealInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:MealInfoCellIdentifier forIndexPath:indexPath];
    
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
    
    return [self.viewModel numberOfSections];
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

@end

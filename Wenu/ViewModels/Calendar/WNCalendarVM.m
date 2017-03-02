//
//  WNCalendarVM.m
//  Wenu
//
//  Created by Ruslan Kurmakaev on 24/07/16.
//  Copyright © 2016 rkurmakaev. All rights reserved.
//

#import "WNCalendarVM.h"
#import "WNSyncManager.h"
#import "Meal.h"
#import "Category.h"
#import "WNDayInfoVM.h"
#import "WNMealInfoCellVM.h"
#import "WNMealDetailVM.h"

@interface WNCalendarVM () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) WNSyncManager *syncManager;

@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, strong) NSDate *firstVisibleDay;
@property (nonatomic, copy) NSArray <WNDayInfoVM *> *visibleDays;
@property (nonatomic, copy) NSString *monthYearOfVisibleWeek;

@property (nonatomic, strong) NSCalendar *calendar;
@property (nonatomic, strong) NSFetchedResultsController *allMealsFetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext *savingContext;

@property (assign, nonatomic) BOOL isSundayFirst;

@end

@implementation WNCalendarVM

@synthesize isSundayFirst = _isSundayFirst;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize addNewMeal;
@synthesize showDetailMeal;

- (instancetype)initWithNavigationTitle:(NSString *)navigationTitle
                            syncManager:(WNSyncManager *)syncManager {
    
    if (self = [super initWithNavigationTitle:navigationTitle]) {
        
        _syncManager = syncManager;
        
        /// Initialize day info view models
        NSMutableArray <WNDayInfoVM *> *tempArray = [[NSMutableArray alloc] initWithCapacity:21];
        
        for (int i = 0; i < 21; ++i) {
            
            [tempArray addObject:[[WNDayInfoVM alloc] init]];
        }
        
        _visibleDays = tempArray;

        /// Initialize calendar and current date
        _calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        [_calendar setLocale:[NSLocale currentLocale]];
        self.selectedDate = [_calendar startOfDayForDate:[NSDate date]];
        
        /// Initialize fetched result controller
        _fetchedResultsController = [Meal MR_fetchAllSortedBy:MealDateDatabaseKey
                                                    ascending:YES
                                                withPredicate:[self mealsPredicateForDate:_selectedDate]
                                                      groupBy:nil
                                                     delegate:self
                                                    inContext:[NSManagedObjectContext MR_defaultContext]];
        _fetchedResultsController.fetchRequest.fetchBatchSize = 10;
        [_fetchedResultsController performFetch:nil];

        _allMealsFetchedResultsController = [Meal MR_fetchAllSortedBy:MealTitleDatabaseKey
                                                            ascending:YES
                                                        withPredicate:[self allVisibleMealsDaysPredicate]
                                                              groupBy:nil
                                                             delegate:self
                                                            inContext:[NSManagedObjectContext MR_defaultContext]];
        
        @weakify(self)
        [[[NSNotificationCenter defaultCenter] rac_addObserverForName:WNCalendarFirstWekDayChangedNotification
                                                              object:nil] subscribeNext:^(NSNotification *notification) {
            
            @strongify(self)
            [self setIsSundayFirst:[notification.userInfo[WNFirstWeekDayNumberNotification] boolValue]];
        }];
    }
    
    return self;
}

- (void)viewWillAppear {
    
    [self.syncManager requestMeals:nil withCompletion:nil];
}

#pragma mark - Public actions

- (void)setFirstVisibleDay:(NSDate *)firstVisibleDay {
    
    _firstVisibleDay = firstVisibleDay;
    
    NSDateComponents *components = [self.calendar components:NSCalendarUnitYear | NSCalendarUnitMonth fromDate:[_firstVisibleDay WN_dateByAddingWeek]];
    
    self.monthYearOfVisibleWeek = [NSString stringWithFormat:@"%@ %li", [self.calendar standaloneMonthSymbols][[components month] - 1], [components year]];
    
    self.allMealsFetchedResultsController.fetchRequest.predicate = [self allVisibleMealsDaysPredicate];
    [self updateDayViewModels];
}

- (void)setIsSundayFirst:(BOOL)isSundayFirst {
    
    _isSundayFirst = isSundayFirst;
    [self.calendar setFirstWeekday:_isSundayFirst ? 1 : 2];
    
    [self setSelectedDate:_selectedDate];
}

- (nonnull NSString *)weekdaySymbol:(NSInteger)indexOfDay {
    
    return [self.calendar veryShortWeekdaySymbols][self.isSundayFirst ? indexOfDay : (indexOfDay + 1) % 7];
}

- (void)selectDate:(nonnull NSDate *)date {
    
    self.selectedDate = [self.calendar startOfDayForDate:date];
}

- (void)showNextWeekend {
    
    self.firstVisibleDay = [_firstVisibleDay WN_dateByAddingWeek];
}

- (void)showPreviousWeekend {
    
    self.firstVisibleDay = [_firstVisibleDay WN_dateBySubtractingWeek];
}

- (void)refreshData {
    
    [(id<RACSubscriber>)(self.refreshingStarted) sendNext:nil];

    @weakify(self)
    [self.syncManager requestMeals:_selectedDate withCompletion:^{
        
        @strongify(self)
        
        if (self == nil)
            return ;
        
        [(id<RACSubscriber>)(self.refreshingFinished) sendNext:nil];
    }];
}

- (id <MealInfoCellVM>)mealInfoForIndexPath:(nonnull NSIndexPath *)indexPath {
    
    WNMealInfoCellVM *vm = [[WNMealInfoCellVM alloc] init];
    
    Meal *meal = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    vm.title = meal.mealTitle;

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];

    vm.time = [dateFormatter stringFromDate:meal.daytime];
    vm.syncState = [meal.syncstate integerValue];
    
    return vm;
}

- (void)deleteMealAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        
        Meal *meal = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        if ([meal.syncstate integerValue] == WNMealSyncStateNeedToUpload) {
            
            [meal MR_deleteEntityInContext:localContext];
            meal = nil;
            return;
        }
        meal.syncstate = @(WNMealSyncStateNeedToDelete);
    } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
        
        Meal *meal = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self.syncManager syncMeal:meal.identifier];
    }];
}

- (void)goToMealDetailInfo:(NSIndexPath *)indexPath {
    
    Meal *meal = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *mealID = meal.identifier;
    
    if (self.showDetailMeal) {
        
        self.showDetailMeal(mealID);
    }
}

- (void)goToAddingMeal {
    
    if (self.addNewMeal) {
        
        self.addNewMeal();
    }
}

- (NSInteger)numberOfSections {
    
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section {
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

#pragma mark - Private actions

- (void)updateDayViewModels {
    
    NSDate *date = self.firstVisibleDay;
    
    for (int i = 0; i < 21; ++i) {
        
        WNDayInfoVM *model = _visibleDays[i];
        
        model.day = date;
        model.title = [NSString stringWithFormat:@"%li", [self.calendar component:NSCalendarUnitDay fromDate:date]];
        model.isSelected = [_selectedDate isEqual:date];
        NSPredicate *predicate = [self mealsPredicateForDate:date];
        model.hasMeals = [Meal MR_countOfEntitiesWithPredicate:predicate] != 0;
        
        date = [date WN_dateByAddingDay];
    }
}

- (NSPredicate *)mealsPredicateForDate:(NSDate *)date {
    
    return [NSPredicate predicateWithFormat:@"%K >= %@ && %K <= %@", MealDateDatabaseKey, date, MealDateDatabaseKey, [date dateByAddingTimeInterval:SecondsInDay - 1]];
}

- (NSPredicate *)allVisibleMealsDaysPredicate {
    
    return [NSPredicate predicateWithFormat:@"%K >= %@ && %K <= %@", MealDateDatabaseKey, _firstVisibleDay, MealDateDatabaseKey, [_firstVisibleDay dateByAddingTimeInterval:3 * SecondsInWeek]];
}

#pragma mark - Setters

- (void)setSelectedDate:(NSDate *)selectedDate {
    
    _selectedDate = selectedDate;
    
    NSDate *date = nil;
    [self.calendar rangeOfUnit:NSCalendarUnitWeekOfYear
                     startDate:&date
                      interval:NULL
                       forDate:_selectedDate];
    date = [date WN_dateBySubtractingWeek];
    self.firstVisibleDay = date;
    
    [self.fetchedResultsController.fetchRequest setPredicate:[self mealsPredicateForDate:_selectedDate]];
    [self.fetchedResultsController performFetch:nil];
    [(id<RACSubscriber>)(self.reloadData) sendNext:nil];
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    if ([controller isEqual:self.fetchedResultsController]) {

        [(id<RACSubscriber>)(self.willChangeContentSignal) sendNext:nil];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    if ([controller isEqual:self.fetchedResultsController]) {

        [(id<RACSubscriber>)(self.itemChangeSignal) sendNext:RACTuplePack(indexPath, @(type), newIndexPath)];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    if ([controller isEqual:self.fetchedResultsController]) {

        [(id<RACSubscriber>)(self.sectionChangeSignal) sendNext:RACTuplePack(@(sectionIndex), @(type))];
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    if ([controller isEqual:self.fetchedResultsController]) {

        [(id<RACSubscriber>)(self.didChangeContentSignal) sendNext:nil];
        
    } else if ([controller isEqual:self.allMealsFetchedResultsController]) {
            
        [self updateDayViewModels];
    }
}

@end

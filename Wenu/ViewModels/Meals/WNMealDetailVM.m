//
//  WNMealDetailVM.m
//  Wenu
//
//  Created by Ruslan Kurmakaev on 31/07/16.
//  Copyright © 2016 rkurmakaev. All rights reserved.
//

#import "WNMealDetailVM.h"
#import "Meal.h"
#import "Category.h"
#import "WNSyncManager.h"

@interface WNMealDetailVM () <NSFetchedResultsControllerDelegate>

@property (nonatomic, weak) WNSyncManager *syncManager;

@property (nonatomic, copy) NSString *mealID;
@property (nonatomic, copy) NSString *mealTitle;
@property (nonatomic, copy) NSString *dateString;
@property (nonatomic, copy) NSString *mealDescription;
@property (nonatomic, copy) NSString *pictureURL;
@property (nonatomic, copy) NSArray <NSString *> *categories;
@property (nonatomic, assign) BOOL isSynchronized;

@property (nonatomic, strong) RACSignal *goBack;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end


@implementation WNMealDetailVM

@synthesize navigationTitle = _navigationTitle;
@synthesize editMeal;

- (instancetype)initWithNavigationTitle:(NSString *)title
                                 mealID:(NSString *)mealID
                            syncManager:(WNSyncManager *)syncManager {
    
    if (self = [super init]) {
        
        _navigationTitle = title;
        _mealID = mealID;
        _syncManager = syncManager;
        
        self.goBack = [[RACSubject subject] setNameWithFormat:@"%@ goBack", NSStringFromClass([self class])];

        _fetchedResultsController = [Meal MR_fetchAllSortedBy:MealTitleDatabaseKey
                                                    ascending:YES
                                                withPredicate:[NSPredicate predicateWithFormat:@"%K == %@", MealIDDatabaseKey, mealID]
                                                      groupBy:nil
                                                     delegate:self];
        [_fetchedResultsController performFetch:nil];
        [self updateData];
    }
    
    return self;
}

#pragma mark - Public

- (void)synchronizeWithServer {
    
    [self.syncManager syncMeal:self.mealID];
}

- (void)goToEditingMeal {
    
    if (self.editMeal) {
        
        self.editMeal(self.mealID);
    }
}

#pragma mark - Private

- (void)updateData {
    
    if ([self.fetchedResultsController.fetchedObjects count] == 0) {
        
        ///FIX IT! Must update data if requested new ID.
        [(id<RACSubscriber>)(self.goBack) sendNext:nil];
        return ;
    }
    
    Meal *meal = [self.fetchedResultsController fetchedObjects][0];
    
    self.mealTitle = meal.mealTitle;
    self.mealDescription = meal.mealDescirption;
    self.pictureURL = meal.pictureURL;
    self.isSynchronized = [meal.syncstate integerValue] == WNMealSyncStateSynchronized;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterFullStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    self.dateString = [dateFormatter stringFromDate:meal.daytime];
    
    NSMutableArray *categoriesArray = [[NSMutableArray alloc] init];
    
    for (Category *category in meal.categories) {
        
        [categoriesArray addObject:category.name];
    }
    
    self.categories = categoriesArray;
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    [self updateData];
}

@end

//
//  WNMealsListVM.m
//  Wenu
//
//  Created by Ruslan Kurmakaev on 31/07/16.
//  Copyright © 2016 rkurmakaev. All rights reserved.
//

#import "WNMealsListVM.h"
#import "Meal.h"
#import "Category.h"
#import "WNSyncManager.h"
#import "WNMealInfoCellVM.h"

@interface WNMealsListVM ()

@property (nonatomic, weak) WNSyncManager *syncManager;
@property (nonatomic, copy, nullable) NSString *categoryID;
@property (nonatomic, assign) BOOL showMealsWithoutCategory;
@property (nonatomic, copy) NSArray *categoryNamesInFetchRequest;

@end


@implementation WNMealsListVM

@synthesize searchQuery = _searchQuery;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize showDetailMeal;
@synthesize addNewMeal;
@synthesize showFilter;

- (instancetype)initWithNavigationTitle:(NSString *)navigationTitle
                           showCategory:(nullable NSString *)categoryID
                            syncManager:(WNSyncManager *)syncManager {
    
    if (self = [super initWithNavigationTitle:navigationTitle]) {
        
        _categoryID = categoryID;
        _syncManager = syncManager;
        _showMealsWithoutCategory = YES;
    
        _fetchedResultsController = [Meal MR_fetchAllSortedBy:MealTitleDatabaseKey
                                                    ascending:YES
                                                withPredicate:[self mealsPredicate]
                                                      groupBy:nil
                                                     delegate:self
                                                    inContext:[NSManagedObjectContext MR_defaultContext]];
        
        _fetchedResultsController.fetchRequest.fetchBatchSize = 10;
    }
    
    return self;
}

#pragma mark - Setters

- (void)setSearchQuery:(NSString *)searchQuery {
    
    _searchQuery = searchQuery;
    
    [self updateFetchRequest];
}

#pragma mark - Public actions

- (void)goToMealDetailInfo:(NSIndexPath *)indexPath {
    
    if (self.showDetailMeal) {
        
        Meal *meal = [self.fetchedResultsController objectAtIndexPath:indexPath];
        self.showDetailMeal(meal.identifier);
    }
}

- (void)goToFilter {
    
    if (self.showFilter) {
        
        @weakify(self)
        self.showFilter(^(BOOL applied, BOOL showMealsWithoutCategory, NSArray *categoryNames){
        
            @strongify(self)
            
            if (!self)
                return ;
            
            if (applied) {
                
                self.showMealsWithoutCategory = showMealsWithoutCategory;
                self.categoryNamesInFetchRequest = categoryNames;
                [self updateFetchRequest];
            }
        });
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

- (id <MealInfoCellVM>)mealInfoForIndexPath:(NSIndexPath *)indexPath {
    
    id <MealInfoCellVM> mealInfoVM = [[WNMealInfoCellVM alloc] init];
    
    Meal *meal = [self.fetchedResultsController objectAtIndexPath:indexPath];
    mealInfoVM.title = meal.mealTitle;
    mealInfoVM.syncState = [meal.syncstate integerValue];

    return mealInfoVM;
}

- (void)deleteMealAtIndexPath:(NSIndexPath *)indexPath {
    
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

#pragma mark - Private actions

- (NSPredicate *)mealsPredicate {
    
    NSMutableArray *predicates = [[NSMutableArray alloc] init];
    
    if ([_searchQuery length] != 0) {
        
        [predicates addObject:[NSPredicate predicateWithFormat:@"%K CONTAINS[c] %@", MealTitleDatabaseKey, self.searchQuery]];
    }
    NSMutableArray *categoriesPredicate = [[NSMutableArray alloc] init];
    
    if (self.categoryNamesInFetchRequest != nil && [self.categoryNamesInFetchRequest count] != 0) {
        
        [categoriesPredicate addObject:[NSPredicate predicateWithFormat:@"ANY categories.name IN %@",self.categoryNamesInFetchRequest]];
    }
    
    if (self.showMealsWithoutCategory && [categoriesPredicate count] != 0) {
        
        [categoriesPredicate addObject:[NSPredicate predicateWithFormat:@"%K.@count == 0", MealCategoriesDatabaseKey]];
    }
    
    if ([categoriesPredicate count]) {
        
        [predicates addObject:[NSCompoundPredicate orPredicateWithSubpredicates:categoriesPredicate]];
    }
    
    if ([predicates count] == 0) {
        
        return [NSPredicate predicateWithValue:YES];
    }
    
    return [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
}

- (void)updateFetchRequest {
    
    self.fetchedResultsController.fetchRequest.predicate = [self mealsPredicate];
    [self.fetchedResultsController performFetch:nil];
    [(id<RACSubscriber>)(self.reloadData) sendNext:nil];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    [(id<RACSubscriber>)(self.willChangeContentSignal) sendNext:nil];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    [(id<RACSubscriber>)(self.itemChangeSignal) sendNext:RACTuplePack(indexPath, @(type), newIndexPath)];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    [(id<RACSubscriber>)(self.sectionChangeSignal) sendNext:RACTuplePack(@(sectionIndex), @(type))];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    [(id<RACSubscriber>)(self.didChangeContentSignal) sendNext:nil];
}

@end

//
//  WNAddCategoryVM.m
//  Wenu
//
//  Created by Ruslan Kurmakaev on 04/08/16.
//  Copyright © 2016 rkurmakaev. All rights reserved.
//

#import "WNAddCategoryVM.h"
#import "Meal.h"
#import "Category.h"
#import "WNItemWithCheckStateVM.h"

@interface WNAddCategoryVM () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, copy) NSMutableArray <id <ItemWithCheckStateVM> > *viewModels;

@end


@implementation WNAddCategoryVM

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize categoryName;

- (instancetype)initWithNavigationTitle:(NSString *)navigationTitle {
    
    if (self = [super initWithNavigationTitle:navigationTitle]) {
        
        _context = [NSManagedObjectContext MR_defaultContext];
        
        _fetchedResultsController = [Meal MR_fetchAllSortedBy:MealTitleDatabaseKey
                                                    ascending:YES
                                                withPredicate:[NSPredicate predicateWithValue:YES]
                                                      groupBy:nil
                                                     delegate:self
                                                    inContext:self.context];
        
        _fetchedResultsController.fetchRequest.fetchBatchSize = 10;
        
        _viewModels = [[NSMutableArray alloc] init];
        
        for (Meal *meal in [_fetchedResultsController fetchedObjects]) {
            
            id <ItemWithCheckStateVM> mealVM = [[WNItemWithCheckStateVM alloc] initWithName:meal.mealTitle
                                                                              andCheckState:NO];
            
            [_viewModels addObject:mealVM];
        }
    }
    
    return self;
}

#pragma mark - Public actions

- (id <ItemWithCheckStateVM>)viewModelForIndexPath:(NSIndexPath *)indexPath {
    
    return [self.viewModels objectAtIndex:indexPath.row];
}

- (void)saveChanges {
    
    [self.viewModels makeObjectsPerformSelector:@selector(saveIsCheckValue)];

    [self.context MR_saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        
        self.categoryName = [self.categoryName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        Category *category = [Category MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"%K == %@", CategoryNameDatabaseKey, self.categoryName]
                                                       inContext:localContext];
        
        if (category == nil) {
            
            category = [Category MR_createEntityInContext:localContext];
            [category setName:self.categoryName];
        }
        
        for (int i = 0; i < [self.viewModels count]; ++i) {
            
            if (self.viewModels[i].isChecked) {
                
                Meal *meal = [self.fetchedResultsController fetchedObjects][i];
                [category addMealsObject:meal];
                [meal setSyncstate:@(WNMealSyncStateNeedToUpdate)];
            }
        }
    }];
}

- (NSInteger)numberOfSections {
    
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section {
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    [(id<RACSubscriber>)(self.willChangeContentSignal) sendNext:nil];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert: {
            
            Category *category = anObject;
            id <ItemWithCheckStateVM> mealVM = [[WNItemWithCheckStateVM alloc] initWithName:category.name
                                                                              andCheckState:NO];
            
            if (newIndexPath.row <= [self.viewModels count]) {
                
                [self.viewModels insertObject:mealVM atIndex:newIndexPath.row];
            }
            else {
                
                [self.viewModels addObject:mealVM];
            }
        }
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.viewModels removeObjectAtIndex:indexPath.row];
            break;
            
        case NSFetchedResultsChangeUpdate:
            break;
            
        case NSFetchedResultsChangeMove: {
            
            id <ItemWithCheckStateVM> mealVM = [self.viewModels objectAtIndex:indexPath.row];
            [self.viewModels removeObjectAtIndex:indexPath.row];
            [self.viewModels insertObject:mealVM atIndex:newIndexPath.row];
        }
            break;
    }
    
    [(id<RACSubscriber>)(self.itemChangeSignal) sendNext:RACTuplePack(indexPath, @(type), newIndexPath)];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    [(id<RACSubscriber>)(self.sectionChangeSignal) sendNext:RACTuplePack(@(sectionIndex), @(type))];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    [(id<RACSubscriber>)(self.didChangeContentSignal) sendNext:nil];
}

@end

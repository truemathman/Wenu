//
//  WNAddOrEditMealVM.m
//  Wenu
//
//  Created by Ruslan Kurmakaev on 31/07/16.
//  Copyright © 2016 rkurmakaev. All rights reserved.
//

#import "WNAddOrEditMealVM.h"
#import "Meal.h"
#import "WNSyncManager.h"
#import "Category.h"
#import "WNItemWithCheckStateVM.h"

@interface WNAddOrEditMealVM () <NSFetchedResultsControllerDelegate>

@property (nonatomic, copy, nullable) NSString *dateString;

@property (nonatomic, strong, nullable) Meal *meal;
@property (nonatomic, copy, nullable) NSSet *categoryNamesOfEntity;
@property (nonatomic, copy) NSMutableArray <WNItemWithCheckStateVM *> *viewModels;

@property (nonatomic, weak) WNSyncManager *syncManager;
@property (nonatomic, strong) NSManagedObjectContext *context;

@end


@implementation WNAddOrEditMealVM

@synthesize mealTitle = _mealTitle;
@synthesize mealDescription = _mealDescription;
@synthesize date = _date;
@synthesize pictureURL = _pictureURL;
@synthesize imagePathURL = _imagePathURL;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize addNewCategory;

- (instancetype)initWithNavigationTitle:(NSString *)navigationTitle
                                 mealID:(nullable NSString *)ID
                            syncManager:(WNSyncManager *)syncManager {
    
    if (self = [super initWithNavigationTitle:navigationTitle]) {
        
        _syncManager = syncManager;
        
        _context = [NSManagedObjectContext MR_defaultContext];
        if (ID) {
            
            _meal = [Meal MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"%K == %@", MealIDDatabaseKey, ID]
                                          inContext:_context];
        }
        
        if (_meal == nil) {
            
            [self setDate:[NSDate date]];
        }
        else {
            
            _categoryNamesOfEntity = [_meal.categories valueForKeyPath:CategoryNameDatabaseKey];
            
            _mealTitle = _meal.mealTitle;
            _mealDescription = _meal.mealDescirption;
            [self setDate:_meal.daytime];
        }
        
        _fetchedResultsController = [Category MR_fetchAllSortedBy:CategoryNameDatabaseKey
                                                        ascending:YES
                                                    withPredicate:[NSPredicate predicateWithValue:YES]
                                                          groupBy:nil
                                                         delegate:self
                                                        inContext:_context];
        _fetchedResultsController.fetchRequest.fetchBatchSize = 10;
        [_fetchedResultsController performFetch:nil];
        
        _viewModels = [[NSMutableArray alloc] init];
        
        for (Category *category in [_fetchedResultsController fetchedObjects]) {
            
            BOOL isChecked = _categoryNamesOfEntity != nil && [_categoryNamesOfEntity containsObject:category.name];
            
            id <ItemWithCheckStateVM> categoryVM =
                [[WNItemWithCheckStateVM alloc] initWithName:category.name
                                               andCheckState:isChecked];
            
            [_viewModels addObject:categoryVM];
        }
    }
    
    return self;
}

#pragma mark - Setters

- (void)setDate:(NSDate *)date {
    
    _date = date;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    self.dateString = [dateFormatter stringFromDate:_date];
}

#pragma mark - Public actions

- (void)saveChanges {
    
    [self.viewModels makeObjectsPerformSelector:@selector(saveIsCheckValue)];

    if (!self.meal) {
        
        self.meal = [Meal MR_createEntityInContext:self.context];
    }
    
    [self.context MR_saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        
        self.meal.mealDescirption = [_mealDescription stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        self.meal.uploadingPictureURL = [_imagePathURL absoluteString];
        self.meal.mealTitle = [_mealTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        self.meal.daytime = _date;

        for (int i = 0; i < [self.viewModels count]; ++i) {
            
            if (self.viewModels[i].isChecked && ![[self.meal.categories valueForKeyPath:CategoryNameDatabaseKey] containsObject:self.viewModels[i].name]) {
                
                [self.meal addCategoriesObject:[Category MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"%K == %@", CategoryNameDatabaseKey, self.viewModels[i].name]
                                                                    inContext:localContext]];
            }
        }

        if (self.meal.identifier == nil) {
            
            self.meal.syncstate = @(WNMealSyncStateNeedToUpload);
            self.meal.identifier = [[[self.meal objectID] URIRepresentation] absoluteString];
        }
        else {
            
            self.meal.syncstate = @(WNMealSyncStateNeedToUpdate);
        }
    } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
        
        [self.syncManager syncMeal:self.meal.identifier];
    }];
}

- (void)cancelChanges {
    
    self.meal = nil;
    [self.context reset];
}

- (void)goToAddingNewCategory {
    
    if (self.addNewCategory) {
        
        self.addNewCategory();
    }
}

- (id <ItemWithCheckStateVM>)categoryForIndexPath:(nonnull NSIndexPath *)indexPath {
    
    return [self.viewModels objectAtIndex:indexPath.row];
}

#pragma mark - NSFetchedResultsController actions

- (NSInteger)numberOfSections {
    
    return [self.viewModels count] ? 1 : 0;
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section {
    
    return [self.viewModels count];
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    [(id<RACSubscriber>)(self.willChangeContentSignal) sendNext:nil];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    switch(type)
    {
        case NSFetchedResultsChangeInsert: {
            
            Category *category = anObject;
            
            id <ItemWithCheckStateVM> vm = [[WNItemWithCheckStateVM alloc] initWithName:category.name andCheckState:self.categoryNamesOfEntity != nil && [self.categoryNamesOfEntity containsObject:category.name]];
            
            if ([category.meals count] == 0) {
                
                [vm setIsChecked:YES];
            }
            
            if (newIndexPath.row <= [self.viewModels count]) {
                
                [self.viewModels insertObject:vm atIndex:newIndexPath.row];
            }
            else {
                
                [self.viewModels addObject:vm];
            }
        }
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.viewModels removeObjectAtIndex:indexPath.row];
            break;
            
        case NSFetchedResultsChangeUpdate: {
            
            Category *category = anObject;

            [[self.viewModels objectAtIndex:indexPath.row] setIsChecked:self.categoryNamesOfEntity != nil && [self.categoryNamesOfEntity containsObject:category.name]];
        }
            break;
            
        case NSFetchedResultsChangeMove: {
            WNItemWithCheckStateVM *vm = [self.viewModels objectAtIndex:indexPath.row];
            [self.viewModels removeObjectAtIndex:indexPath.row];
            [self.viewModels insertObject:vm atIndex:newIndexPath.row];
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

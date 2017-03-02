//
//  WNFilterMealsVM.m
//  Wenu
//
//  Created by Ruslan Kurmakaev on 01/08/16.
//  Copyright © 2016 rkurmakaev. All rights reserved.
//

#import "WNFilterMealsVM.h"
#import "Category.h"
#import "WNItemWithCheckStateVM.h"

@interface WNFilterMealsVM () <NSFetchedResultsControllerDelegate>

@property (nonatomic, copy) NSMutableArray <id <ItemWithCheckStateVM> > *viewModels;

@end


@implementation WNFilterMealsVM

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize completion;

- (instancetype)initWithNavigationTitle:(NSString *)navigationTitle {
    
    if (self = [super initWithNavigationTitle:navigationTitle]) {
        
        _viewModels = [[NSMutableArray alloc] initWithObjects:[[WNItemWithCheckStateVM alloc]
                                                               initWithName:@"Without category" andCheckState:YES], nil];
        
        _fetchedResultsController = [Category MR_fetchAllSortedBy:CategoryNameDatabaseKey
                                                        ascending:YES
                                                    withPredicate:[NSPredicate predicateWithValue:YES]
                                                          groupBy:nil
                                                         delegate:self
                                                        inContext:[NSManagedObjectContext MR_defaultContext]];
        [_fetchedResultsController performFetch:nil];
        
        for (Category *category in [_fetchedResultsController fetchedObjects]) {
            
            id <ItemWithCheckStateVM> categoryVM = [[WNItemWithCheckStateVM alloc] initWithName:category.name
                                                                                  andCheckState:YES];
            [_viewModels addObject:categoryVM];
        }
    }
    
    return self;
}

#pragma mark - Public actions

- (NSInteger)numberOfSections {
    
    return 1;
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section {
    
    return [self.viewModels count];
}

- (nonnull WNItemWithCheckStateVM *)categoryForIndexPath:(nonnull NSIndexPath *)indexPath {
    
    return [self.viewModels objectAtIndex:indexPath.row];
}

- (void)selectAll {
    
    for (WNItemWithCheckStateVM *categoryVM in self.viewModels) {
        
        [categoryVM setIsChecked:YES];
    }
    
    [(id<RACSubscriber>)(self.reloadData) sendNext:nil];
}

- (void)deselectAll {
    
    for (WNItemWithCheckStateVM *categoryVM in self.viewModels) {
        
        [categoryVM setIsChecked:NO];
    }
    
    [(id<RACSubscriber>)(self.reloadData) sendNext:nil];
}

- (void)cancelChanges {
    
    [self.viewModels makeObjectsPerformSelector:@selector(restoreIsCheckValueToPreviousState)];
    
    if (self.completion) {
        
        self.completion(NO, NO, nil);
    }
}

- (void)applyChanges {
    
    [self.viewModels makeObjectsPerformSelector:@selector(saveIsCheckValue)];
    
    BOOL withoutCategory = [[self.viewModels firstObject] isChecked];
    NSMutableArray *categoryNames = [[NSMutableArray alloc] init];
    
    WNItemWithCheckStateVM *vm;
    
    for (int i = 1; i < [self.viewModels count]; ++i) {
        
        vm = [self.viewModels objectAtIndex:i];
        if (vm.isChecked) {
            
            [categoryNames addObject:vm.name];
        }
    }
    
    if ([categoryNames count] == [self.viewModels count] - 1 && withoutCategory) {
        
        categoryNames = nil;
    }
    
    if (self.completion) {
        
        self.completion(YES, withoutCategory, categoryNames);
    }
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    [(id<RACSubscriber>)(self.willChangeContentSignal) sendNext:nil];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    indexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
    newIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row + 1 inSection:newIndexPath.section];

    switch(type)
    {
        case NSFetchedResultsChangeInsert: {
            
            Category *category = anObject;
            WNItemWithCheckStateVM *vm = [[WNItemWithCheckStateVM alloc] initWithName:category.name andCheckState:YES];
            
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
            
        case NSFetchedResultsChangeUpdate:
            [[self.viewModels objectAtIndex:indexPath.row] setIsChecked:YES];
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

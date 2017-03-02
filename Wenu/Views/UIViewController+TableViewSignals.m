//
//  UIViewController+TableViewSignals.m
//  Wenu
//
//  Created by Ruslan Kurmakaev on 01/03/17.
//  Copyright © 2017 rkurmakaev. All rights reserved.
//

#import "UIViewController+TableViewSignals.h"
#import "TableViewVM.h"

@implementation UIViewController (TableViewSignals)

- (void)subscribeTableView:(UITableView *)tableView toViewModel:(id <TableViewVM>)viewModel {
    
    @weakify(self, viewModel, tableView)
    [[viewModel.willChangeContentSignal takeUntil:[self rac_willDeallocSignal]] subscribeNext:^(id _) {
        @strongify(tableView)
        
        if (tableView == nil)
            return ;
        
        [tableView beginUpdates];
    }];
    
    [[viewModel.itemChangeSignal takeUntil:[self rac_willDeallocSignal]] subscribeNext:^(RACTuple *params) {
        @strongify(tableView)
        
        if (tableView == nil)
            return ;
        
        RACTupleUnpack(NSIndexPath *indexPath, NSNumber *typeNumber, NSIndexPath *newIndexPath) = params;
        NSFetchedResultsChangeType type = typeNumber.unsignedIntegerValue;
        
        switch(type)
        {
            case NSFetchedResultsChangeInsert:
                [tableView insertRowsAtIndexPaths:@[newIndexPath]
                                          withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
                
            case NSFetchedResultsChangeDelete:
                [tableView deleteRowsAtIndexPaths:@[indexPath]
                                          withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
                
            case NSFetchedResultsChangeUpdate:
                [tableView reloadRowsAtIndexPaths:@[indexPath]
                                          withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
                
            case NSFetchedResultsChangeMove:
                [tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
                break;
        }
    }];
    
    [[viewModel.sectionChangeSignal takeUntil:[self rac_willDeallocSignal]] subscribeNext:^(RACTuple *params) {
        @strongify(tableView)
        
        if (tableView == nil)
            return ;
        
        RACTupleUnpack(NSNumber *sectionIndexNumber, NSNumber *typeNumer) = params;
        NSUInteger sectionIndex = sectionIndexNumber.unsignedIntegerValue;
        NSUInteger type = typeNumer.unsignedIntegerValue;
        
        switch(type) {
            case NSFetchedResultsChangeInsert:
                [tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeDelete:
                [tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                break;
        }
    }];
    
    [[viewModel.didChangeContentSignal takeUntil:[self rac_willDeallocSignal]] subscribeNext:^(id _) {
        @strongify(tableView)
        
        if (tableView == nil)
            return ;
        
        [tableView endUpdates];
    }];
    
    [[viewModel.reloadData takeUntil:[self rac_willDeallocSignal]] subscribeNext:^(id _) {
        @strongify(tableView)
        
        if (tableView == nil)
            return ;
        
        [tableView reloadData];
    }];
}

@end

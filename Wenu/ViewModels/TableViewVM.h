//
//  TableViewVM.h
//  Wenu
//
//  Created by Ruslan Kurmakaev on 01/03/17.
//  Copyright © 2017 rkurmakaev. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

@protocol TableViewVM <NSFetchedResultsControllerDelegate>

@property (nonatomic, copy, readonly) NSString *navigationTitle;

@property (nonatomic, strong, readonly) RACSignal *willChangeContentSignal;
@property (nonatomic, strong, readonly) RACSignal *itemChangeSignal;
@property (nonatomic, strong, readonly) RACSignal *sectionChangeSignal;
@property (nonatomic, strong, readonly) RACSignal *didChangeContentSignal;
@property (nonatomic, strong, readonly) RACSignal *reloadData;

@property (nonatomic, strong, readonly) RACSignal *refreshingStarted;
@property (nonatomic, strong, readonly) RACSignal *refreshingFinished;

@property (nonatomic, strong, readonly) NSFetchedResultsController *fetchedResultsController;

- (NSInteger)numberOfSections;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;

@end

NS_ASSUME_NONNULL_END

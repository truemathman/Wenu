//
//  AddOrEditMealVM.h
//  Wenu
//
//  Created by Ruslan Kurmakaev on 01/03/17.
//  Copyright © 2017 rkurmakaev. All rights reserved.
//

#import "TableViewVM.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ItemWithCheckStateVM;

@protocol AddOrEditMealCoordinatorVM <NSObject>

@property (nonatomic, copy) void (^addNewCategory)();

@end


@protocol AddOrEditMealVM <TableViewVM>

@property (nonatomic, copy, nullable) NSString *mealTitle;
@property (nonatomic, copy, nullable, readonly) NSString *dateString;
@property (nonatomic, strong, nullable) NSDate *date;
@property (nonatomic, copy, nullable) NSString *mealDescription;
@property (nonatomic, copy, nullable, readonly) NSString *pictureURL;
@property (nonatomic, strong, nullable) NSURL *imagePathURL;

@property (nonatomic, strong) RACSignal *itemChangeSignal;

- (void)saveChanges;
- (void)cancelChanges;

- (void)goToAddingNewCategory;

- (id <ItemWithCheckStateVM>)categoryForIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END

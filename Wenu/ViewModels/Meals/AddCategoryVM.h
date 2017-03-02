//
//  AddCategoryVM.h
//  Wenu
//
//  Created by Ruslan Kurmakaev on 01/03/17.
//  Copyright © 2017 rkurmakaev. All rights reserved.
//

#import "TableViewVM.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ItemWithCheckStateVM;

@protocol AddCategoryVM <TableViewVM>

@property (nonatomic, strong, readonly) RACSignal *itemChangeSignal;
@property (nonatomic, copy) NSString *categoryName;

- (id <ItemWithCheckStateVM>)viewModelForIndexPath:(NSIndexPath *)indexPath;

- (void)saveChanges;

@end

NS_ASSUME_NONNULL_END

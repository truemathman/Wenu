//
//  ItemWithCheckStateVM.h
//  Wenu
//
//  Created by Ruslan Kurmakaev on 01/03/17.
//  Copyright © 2017 rkurmakaev. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

@protocol ItemWithCheckStateVM <NSObject>

@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, assign) BOOL isChecked;

- (void)restoreIsCheckValueToPreviousState;
- (void)saveIsCheckValue;

@end

NS_ASSUME_NONNULL_END

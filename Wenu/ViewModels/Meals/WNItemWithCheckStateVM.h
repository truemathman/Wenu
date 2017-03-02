//
//  CategoryViewModel.h
//  Wenu
//
//  Created by Ruslan Kurmakaev on 01/08/16.
//  Copyright © 2016 rkurmakaev. All rights reserved.
//

#import "ItemWithCheckStateVM.h"

NS_ASSUME_NONNULL_BEGIN

@interface WNItemWithCheckStateVM : NSObject <ItemWithCheckStateVM>

- (instancetype)initWithName:(NSString *)name andCheckState:(BOOL)isChecked;

@end

NS_ASSUME_NONNULL_END

//
//  CategoryCell.h
//  Wenu
//
//  Created by Ruslan Kurmakaev on 01/08/16.
//  Copyright © 2016 rkurmakaev. All rights reserved.
//

#import "WNBaseCell.h"
#import "ItemWithCheckStateVM.h"

NS_ASSUME_NONNULL_BEGIN

@interface WNSwitchCell : WNBaseCell

- (void)configure:(id <ItemWithCheckStateVM>)viewModel;

@end

NS_ASSUME_NONNULL_END

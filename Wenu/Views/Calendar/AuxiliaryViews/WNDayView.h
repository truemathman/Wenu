//
//  WNDayView.h
//  Wenu
//
//  Created by Ruslan Kurmakaev on 28/07/16.
//  Copyright © 2016 rkurmakaev. All rights reserved.
//

#import "CustomView.h"
#import "WNDayInfoVM.h"

NS_ASSUME_NONNULL_BEGIN

@interface WNDayView : CustomView

@property (nonatomic, weak) WNDayInfoVM *viewModel;
@property (nonatomic, copy) void(^onTap)();

@end

NS_ASSUME_NONNULL_END

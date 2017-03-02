//
//  WNDatePickerWithToolbar.h
//  Wenu
//
//  Created by Ruslan Kurmakaev on 02/08/16.
//  Copyright © 2016 rkurmakaev. All rights reserved.
//

#import "CustomView.h"

@interface WNDatePickerWithToolbar : CustomView

@property (nonatomic, copy) void (^onCancel)();
@property (nonatomic, copy) void (^onDateSelected)(NSDate *date);
@property (nonatomic) UIDatePickerMode datePickerMode;

- (void)setDate:(NSDate *)date animated:(BOOL)animated;

@end

//
//  WNDatePickerWithToolbar.m
//  Wenu
//
//  Created by Ruslan Kurmakaev on 02/08/16.
//  Copyright © 2016 rkurmakaev. All rights reserved.
//

#import "WNDatePickerWithToolbar.h"

@interface WNDatePickerWithToolbar ()

@property (nonatomic, strong) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *todayButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *selectButton;

@property (nonatomic, strong) IBOutlet UIDatePicker *datePicker;

@end


@implementation WNDatePickerWithToolbar

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.cancelButton.tintColor = self.todayButton.tintColor = self.selectButton.tintColor = [UIColor mainApplicationColor];
    
    [self.cancelButton setTarget:self];
    [self.cancelButton setAction:@selector(cancelChangingDateButtonPressed:)];
    
    [self.todayButton setTarget:self];
    [self.todayButton setAction:@selector(selectTodayButtonPressed:)];
    
    [self.selectButton setTarget:self];
    [self.selectButton setAction:@selector(selectDateFromPickerButtonPressed:)];
}

- (void)setDate:(NSDate *)date animated:(BOOL)animated {
    
    [self.datePicker setDate:date animated:animated];
}

- (void)setDatePickerMode:(UIDatePickerMode)datePickerMode {
    
    [self.datePicker setDatePickerMode:datePickerMode];
}

- (UIDatePickerMode)datePickerMode {
    
    return self.datePicker.datePickerMode;
}

- (void)cancelChangingDateButtonPressed:(UIBarButtonItem *)sender {
    
    if (self.onCancel)
        self.onCancel();
}

- (void)selectTodayButtonPressed:(UIBarButtonItem *)sender {
    
    if (self.onDateSelected)
        self.onDateSelected([NSDate date]);
}

- (void)selectDateFromPickerButtonPressed:(UIBarButtonItem *)sender {
    
    if (self.onDateSelected)
        self.onDateSelected(self.datePicker.date);
}

@end

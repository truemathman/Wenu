//
//  CategoryViewModel.m
//  Wenu
//
//  Created by Ruslan Kurmakaev on 01/08/16.
//  Copyright © 2016 rkurmakaev. All rights reserved.
//

#import "WNItemWithCheckStateVM.h"

@interface WNItemWithCheckStateVM ()

@property (nonatomic, assign) BOOL isCheckedPreviousState;

@end


@implementation WNItemWithCheckStateVM

@synthesize name = _name;
@synthesize isChecked = _isChecked;

- (instancetype)initWithName:(NSString *)name
               andCheckState:(BOOL)isChecked {
    
    if (self = [super init]) {
        
        _name = name;
        _isChecked = _isCheckedPreviousState = isChecked;
    }
    
    return self;
}

- (void)restoreIsCheckValueToPreviousState {
    
    self.isChecked = self.isCheckedPreviousState;
}

- (void)saveIsCheckValue {
    
    self.isCheckedPreviousState = self.isChecked;
}

@end

//
//  SettingCell.m
//  Wenu
//
//  Created by Ruslan Kurmakaev on 02/08/16.
//  Copyright © 2016 rkurmakaev. All rights reserved.
//

#import "WNSettingCellWithSwitch.h"

@interface WNSettingCellWithSwitch ()

@property (nonatomic, strong) UISwitch *switchControl;

@end


@implementation WNSettingCellWithSwitch

- (instancetype)initWithReusableIdentifier:(NSString *)reuseIdentifier withSwitch:(BOOL)useSwitch {
    
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        
        [self addSeparator];
        
        if (useSwitch) {
            
            _switchControl = [[UISwitch alloc] init];
            
            @weakify(self)
            [[_switchControl rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(id x) {
                
                @strongify(self)
                if (self.action) {
                    
                    self.action();
                }
            }];
            self.accessoryView = _switchControl;
        }
    }
    
    return self;
}

- (void)setSwitchState:(BOOL)isOn {
    
    [self.switchControl setOn:isOn];
}

@end

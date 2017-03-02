//
//  CategoryCell.m
//  Wenu
//
//  Created by Ruslan Kurmakaev on 01/08/16.
//  Copyright © 2016 rkurmakaev. All rights reserved.
//

#import "WNSwitchCell.h"
#import "ItemWithCheckStateVM.h"

@interface WNSwitchCell ()

@property (nonatomic, strong) UISwitch *switchView;
@property (nonatomic, weak) id <ItemWithCheckStateVM> weakViewModel;

@end


@implementation WNSwitchCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self addSeparator];
        
        _switchView = [[UISwitch alloc] init];
        @weakify(self)
        [[[_switchView rac_signalForControlEvents:UIControlEventValueChanged] takeUntil:[self rac_willDeallocSignal]] subscribeNext:^(id x) {
            
            @strongify(self)
            id <ItemWithCheckStateVM> viewModel = self.weakViewModel;
            
            if (viewModel == nil) {
                
                return ;
            }
            
            [self.weakViewModel setIsChecked:self.switchView.isOn];
        }];
        
        self.accessoryView = _switchView;
    }
    
    return self;
}

- (void)configure:(id <ItemWithCheckStateVM>)viewModel {
    
    self.weakViewModel = viewModel;
    
    [self.textLabel setText:viewModel.name];
    [self.switchView setOn:viewModel.isChecked];
}

@end

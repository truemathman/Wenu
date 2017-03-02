//
//  WNDayView.h
//  Wenu
//
//  Created by Ruslan Kurmakaev on 28/07/16.
//  Copyright © 2016 rkurmakaev. All rights reserved.
//

#import "WNDayView.h"

@interface WNDayView ()

@property (nonatomic, strong) IBOutlet UIButton *actionButton;
@property (nonatomic, strong) IBOutlet UIView *bgColorView;
@property (nonatomic, strong) IBOutlet UIView *hasDataIndicator;

@end


@implementation WNDayView

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    [self setBackgroundColor:[UIColor mainApplicationColor]];
    self.hasDataIndicator.layer.cornerRadius = CGRectGetWidth(self.hasDataIndicator.bounds) / 2.f;
    
    [self.actionButton addTarget:self
                          action:@selector(onActionButtonPressed:)
                forControlEvents:UIControlEventTouchUpInside];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.bgColorView.layer.cornerRadius = CGRectGetWidth(self.bgColorView.bounds) / 2.f;
}

- (void)setViewModel:(WNDayInfoVM *)viewModel {
    
    _viewModel = viewModel;

    @weakify(self)
    RAC(self.hasDataIndicator, hidden) = [RACObserve(self, viewModel.hasMeals) not];
    
    [self.actionButton rac_liftSelector:@selector(setTitle:forState:)
                            withSignals:RACObserve(self, viewModel.title),
                                        [RACSignal return:@(UIControlStateNormal)], nil];

    [RACObserve(self.viewModel, isSelected)
     subscribeNext:^(NSNumber *isSelected) {
         @strongify(self)
         
         if (self == nil)
             return ;
         
         self.bgColorView.backgroundColor = [isSelected boolValue] ? [UIColor whiteColor] : [UIColor mainApplicationColor];
         [self.actionButton setTitleColor:[isSelected boolValue] ? [UIColor mainApplicationColor] : [UIColor whiteColor] forState:UIControlStateNormal];
     }];
}

#pragma mark - Private

- (void)onActionButtonPressed:(UIButton *)button {
    
    if (self.onTap) {
        
        self.onTap();
    }
}

@end

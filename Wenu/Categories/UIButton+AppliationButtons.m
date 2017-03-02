//
//  UIButton+AppliationButtons.m
//  Wenu
//
//  Created by Ruslan Kurmakaev on 05/08/16.
//  Copyright © 2016 rkurmakaev. All rights reserved.
//

#import "UIButton+AppliationButtons.h"

@implementation UIButton (AppliationButtons)

- (void)configureDefaultFooterButton {
    
    self.layer.cornerRadius = 8.f;
    self.layer.borderWidth = 1.f;
    self.layer.borderColor = [UIColor mainApplicationColor].CGColor;
}

@end

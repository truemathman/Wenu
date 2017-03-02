//
//  WNEmptyTableViewPlaceholder.m
//  Wenu
//
//  Created by Ruslan Kurmakaev on 01/08/16.
//  Copyright © 2016 rkurmakaev. All rights reserved.
//

#import "WNEmptyTableViewPlaceholder.h"

@implementation WNEmptyTableViewPlaceholder

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.button.layer.borderWidth = 1.f;
    self.button.layer.borderColor = [UIColor mainApplicationColor].CGColor;
    self.button.layer.cornerRadius = 8.f;
    
    self.button.imageView.image = [self.button.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.button.imageView setTintColor:[UIColor mainApplicationColor]];
    [self.label setTextColor:[UIColor mainApplicationColor]];
}

@end

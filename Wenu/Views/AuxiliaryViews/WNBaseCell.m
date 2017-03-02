//
//  WNBaseCell.m
//  Wenu
//
//  Created by Ruslan Kurmakaev on 01/08/16.
//  Copyright © 2016 rkurmakaev. All rights reserved.
//

#import "WNBaseCell.h"

@interface WNBaseCell ()

@property (nonatomic, strong) UIView *separatorView;

@end


@implementation WNBaseCell

- (void)addSeparator {
    
    if (self.separatorView) {
        
        return ;
    }
    
    self.separatorView = [[UIView alloc] initWithFrame:CGRectMake(0.f,
                                                                  CGRectGetHeight(self.bounds) - 0.5f,
                                                                  CGRectGetWidth(self.bounds),
                                                                  0.5f)];
    [self.separatorView setBackgroundColor:[UIColor grayColor]];
    [self.separatorView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self addSubview:self.separatorView];
}

@end

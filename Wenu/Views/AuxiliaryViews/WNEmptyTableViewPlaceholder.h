//
//  WNEmptyTableViewPlaceholder.h
//  Wenu
//
//  Created by Ruslan Kurmakaev on 01/08/16.
//  Copyright © 2016 rkurmakaev. All rights reserved.
//

#import "CustomView.h"

NS_ASSUME_NONNULL_BEGIN

@interface WNEmptyTableViewPlaceholder : CustomView

@property (nonatomic, strong) IBOutlet UILabel *label;
@property (nonatomic, strong) IBOutlet UIButton *button;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *buttonWidth;

@end

NS_ASSUME_NONNULL_END

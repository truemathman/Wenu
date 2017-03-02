//
//  MealInfoCell.m
//  Wenu
//
//  Created by Ruslan Kurmakaev on 31/07/16.
//  Copyright © 2016 rkurmakaev. All rights reserved.
//

#import "WNMealInfoCell.h"
#import "MealInfoCellVM.h"

@interface WNMealInfoCell ()

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *syncstateLabel;
@property (nonatomic, strong) IBOutlet UILabel *timeLabel;

@end


@implementation WNMealInfoCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    [self addSeparator];
}

- (void)configure:(id<MealInfoCellVM>)viewModel {
    
    [self.titleLabel setText:[viewModel title]];
    [self.timeLabel setText:[viewModel time]];
    
    NSString *detailText;
    
    switch ([viewModel syncState]) {
            
        case WNMealSyncStateNeedToDelete:
            detailText = @"Marked for deletion";
            break;
        
        case WNMealSyncStateNeedToUpdate:
            detailText = @"Marked for updating";
            break;
            
        case WNMealSyncStateNeedToUpload:
            detailText = @"Marked for uploading";
            break;
            
        default:
            detailText = @"";
            break;
    }
    
    [self.syncstateLabel setText:detailText];
}

@end

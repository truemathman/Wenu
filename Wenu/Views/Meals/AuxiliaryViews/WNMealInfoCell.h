//
//  MealInfoCell.h
//  Wenu
//
//  Created by Ruslan Kurmakaev on 31/07/16.
//  Copyright © 2016 rkurmakaev. All rights reserved.
//

#import "WNBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MealInfoCellVM;

@interface WNMealInfoCell : WNBaseCell

- (void)configure:(id <MealInfoCellVM>)viewModel;

@end

NS_ASSUME_NONNULL_END

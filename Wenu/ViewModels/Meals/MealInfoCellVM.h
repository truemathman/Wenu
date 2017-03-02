//
//  MealInfoCellVM.h
//  Wenu
//
//  Created by Ruslan Kurmakaev on 01/03/17.
//  Copyright © 2017 rkurmakaev. All rights reserved.
//

#import "WNMealSyncState.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MealInfoCellVM <NSObject>

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, assign) WNMealSyncState syncState;

@end

NS_ASSUME_NONNULL_END

//
//  WNAddOrEditMealVC.h
//  Wenu
//
//  Created by Ruslan Kurmakaev on 31/07/16.
//  Copyright © 2016 rkurmakaev. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AddOrEditMealVM;

@interface WNAddOrEditMealVC : UIViewController

@property (nonatomic, strong) id <AddOrEditMealVM> viewModel;

@end

NS_ASSUME_NONNULL_END

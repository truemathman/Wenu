//
//  WNMealDetailVC.h
//  Wenu
//
//  Created by Ruslan Kurmakaev on 24/07/16.
//  Copyright © 2016 rkurmakaev. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MealDetailVM;

@interface WNMealDetailVC : UIViewController

@property (nonatomic, strong) id <MealDetailVM> viewModel;

@end

NS_ASSUME_NONNULL_END

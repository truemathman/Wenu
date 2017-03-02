//
//  WNFilterMealsVC.h
//  Wenu
//
//  Created by Ruslan Kurmakaev on 01/08/16.
//  Copyright © 2016 rkurmakaev. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FilterMealsVM;

@interface WNFilterMealsVC : UIViewController <UIPopoverControllerDelegate>

@property (nonatomic, strong) id <FilterMealsVM> viewModel;

@end

NS_ASSUME_NONNULL_END

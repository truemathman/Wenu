//
//  WNAddCategoryVC.h
//  Wenu
//
//  Created by Ruslan Kurmakaev on 04/08/16.
//  Copyright © 2016 rkurmakaev. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AddCategoryVM;

@interface WNAddCategoryVC : UIViewController

@property (nonatomic, strong) id <AddCategoryVM> viewModel;

@end

NS_ASSUME_NONNULL_END

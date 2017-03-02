//
//  DayInfoVM.h
//  Wenu
//
//  Created by Ruslan Kurmakaev on 01/03/17.
//  Copyright © 2017 rkurmakaev. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

@protocol DayInfoVM <NSObject>

@property (nonatomic, strong) NSDate *day;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) BOOL hasMeals;

@end

NS_ASSUME_NONNULL_END

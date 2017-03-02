//
//  CalendarVM.h
//  Wenu
//
//  Created by Ruslan Kurmakaev on 01/03/17.
//  Copyright © 2017 rkurmakaev. All rights reserved.
//

#import "TableViewVM.h"

@protocol DayInfoVM;
@protocol MealInfoCellVM;

NS_ASSUME_NONNULL_BEGIN

@protocol CalendarCoordinatorVM <NSObject>

@property (nonatomic, copy) void(^showDetailMeal)(NSString *mealID);
@property (nonatomic, copy) void(^addNewMeal)();

@end


@protocol CalendarVM <TableViewVM>

@property (nonatomic, strong, readonly) NSDate *selectedDate;
@property (nonatomic, strong, readonly) NSDate *firstVisibleDay;
@property (nonatomic, copy, readonly) NSArray <id <DayInfoVM>> *visibleDays;
@property (nonatomic, copy, readonly) NSString *monthYearOfVisibleWeek;

- (NSString *)weekdaySymbol:(NSInteger)indexOfDay;

- (void)selectDate:(NSDate *)date;
- (void)showNextWeekend;
- (void)showPreviousWeekend;

- (void)refreshData;

- (id <MealInfoCellVM>)mealInfoForIndexPath:(NSIndexPath *)indexPath;
- (void)deleteMealAtIndexPath:(NSIndexPath *)indexPath;

- (void)goToMealDetailInfo:(NSIndexPath *)indexPath;
- (void)goToAddingMeal;

@end

NS_ASSUME_NONNULL_END

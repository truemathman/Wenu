//
//  NSDate+NSDate_Weeks.h
//  Wenu
//
//  Created by Ruslan Kurmakaev on 30/07/16.
//  Copyright © 2016 rkurmakaev. All rights reserved.
//

static const NSTimeInterval SecondsInDay = 24 * 60 * 60;
static const NSTimeInterval SecondsInWeek = 7 * SecondsInDay;

@interface NSDate (WNWeeks)

- (NSDate *)WN_dateByAddingDay;
- (NSDate *)WN_dateBySubtractingDay;

- (NSDate *)WN_dateByAddingWeek;
- (NSDate *)WN_dateBySubtractingWeek;

@end

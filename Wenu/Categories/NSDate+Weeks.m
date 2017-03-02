//
//  NSDate+NSDate_Weeks.m
//  Wenu
//
//  Created by Ruslan Kurmakaev on 30/07/16.
//  Copyright © 2016 rkurmakaev. All rights reserved.
//

#import "NSDate+Weeks.h"

@implementation NSDate (WNWeeks)

- (NSDate *)WN_dateByAddingDay {
    
    return [self dateByAddingTimeInterval:SecondsInDay];
}

- (NSDate *)WN_dateBySubtractingDay {
    
    return [self dateByAddingTimeInterval:-SecondsInDay];
}

- (NSDate *)WN_dateByAddingWeek {
    
    return [self dateByAddingTimeInterval:SecondsInWeek];
}

- (NSDate *)WN_dateBySubtractingWeek {
    
    return [self dateByAddingTimeInterval:-SecondsInWeek];
}

@end

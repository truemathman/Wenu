//
//  Meal.h
//  Wenu
//
//  Created by Ruslan Kurmakaev on 28/07/16.
//  Copyright © 2016 rkurmakaev. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "WNMealSyncState.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString * const MealIDDatabaseKey;
extern NSString * const MealIDServerKey;

extern NSString * const MealTitleDatabaseKey;
extern NSString * const MealTitleServerKey;

extern NSString * const MealDateDatabaseKey;
extern NSString * const MealDateServerKey;

extern NSString * const MealDescriptionDatabaseKey;
extern NSString * const MealDescriptionServerKey;

extern NSString * const MealPictureDatabaseKey;
extern NSString * const MealPictureServerKey;

extern NSString * const MealSyncstateDatabaseKey;
extern NSString * const MealCategoriesDatabaseKey;

@interface Meal : NSManagedObject

- (nonnull NSString *)categoriesToString;
+ (nonnull NSString *)pictureURLFromString:(nonnull NSString *)string;

@end

NS_ASSUME_NONNULL_END

#import "Meal+CoreDataProperties.h"

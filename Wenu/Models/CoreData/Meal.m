//
//  Meal.m
//  Wenu
//
//  Created by Ruslan Kurmakaev on 28/07/16.
//  Copyright © 2016 rkurmakaev. All rights reserved.
//

#import "Meal.h"
#import "Category.h"

static NSString * const BaseImagesURL = @"http://ios.favendo.de/pictures/";

NSString * const MealIDDatabaseKey = @"identifier";
NSString * const MealIDServerKey = @"meal_id";

NSString * const MealTitleDatabaseKey = @"mealTitle";
NSString * const MealTitleServerKey = @"meal_title";

NSString * const MealDateDatabaseKey = @"daytime";
NSString * const MealDateServerKey = @"meal_day";

NSString * const MealDescriptionDatabaseKey = @"mealDescirption";
NSString * const MealDescriptionServerKey = @"meal_description";

NSString * const MealPictureDatabaseKey = @"pictureURL";
NSString * const MealPictureServerKey = @"meal_picture";

NSString * const MealSyncstateDatabaseKey = @"syncstate";
NSString * const MealCategoriesDatabaseKey = @"categories";

@implementation Meal

- (void)didImport:(id)data {
    
    self.syncstate = @(0);
}

- (nonnull NSString *)categoriesToString {
    
    NSMutableString *categoriesStr = [[NSMutableString alloc] init];
    for (Category *category in self.categories) {
        
        [categoriesStr appendFormat:@" #%@", category.name];
    }
    
    return categoriesStr;
}

- (BOOL)shouldImport:(id)data {
    
    return [self.syncstate integerValue] == WNMealSyncStateSynchronized;
}

- (void)setSyncstate:(NSNumber *)syncstate {
    
    [self willChangeValueForKey:MealSyncstateDatabaseKey];
    
    if ([[self syncstate] integerValue] != WNMealSyncStateNeedToUpload || [syncstate integerValue] == WNMealSyncStateSynchronized) {
        
        [self setPrimitiveValue:syncstate forKey:MealSyncstateDatabaseKey];
    }
    
    [self didChangeValueForKey:MealSyncstateDatabaseKey];
}

+ (nonnull NSString *)pictureURLFromString:(nonnull NSString *)string {

    NSCharacterSet *charactersToRemove = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    NSString *strippedString = [[string componentsSeparatedByCharactersInSet:charactersToRemove] componentsJoinedByString:@""];
    return [BaseImagesURL stringByAppendingString:[strippedString lowercaseString]];
}

@end

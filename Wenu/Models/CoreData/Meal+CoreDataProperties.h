//
//  Meal+CoreDataProperties.h
//  Wenu
//
//  Created by Ruslan Kurmakaev on 01/08/16.
//  Copyright © 2016 rkurmakaev. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Meal.h"

NS_ASSUME_NONNULL_BEGIN

@class Category;

@interface Meal (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *daytime;
@property (nullable, nonatomic, retain) NSString *mealDescirption;
@property (nullable, nonatomic, retain) NSString *identifier;
@property (nullable, nonatomic, retain) NSString *pictureURL;
@property (nullable, nonatomic, retain) NSNumber *syncstate;
@property (nullable, nonatomic, retain) NSString *mealTitle;
@property (nullable, nonatomic, retain) NSString *uploadingPictureURL;
@property (nullable, nonatomic, retain) NSSet<Category *> *categories;

@end

@interface Meal (CoreDataGeneratedAccessors)

- (void)addCategoriesObject:(Category *)value;
- (void)removeCategoriesObject:(Category *)value;
- (void)addCategories:(NSSet<Category *> *)values;
- (void)removeCategories:(NSSet<Category *> *)values;

@end

NS_ASSUME_NONNULL_END

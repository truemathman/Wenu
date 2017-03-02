//
//  Category+CoreDataProperties.h
//  Wenu
//
//  Created by Ruslan Kurmakaev on 01/08/16.
//  Copyright © 2016 rkurmakaev. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Category.h"

NS_ASSUME_NONNULL_BEGIN

@class Meal;
@interface Category (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSSet<Meal *> *meals;

@end

@interface Category (CoreDataGeneratedAccessors)

- (void)addMealsObject:(Meal *)value;
- (void)removeMealsObject:(Meal *)value;
- (void)addMeals:(NSSet<Meal *> *)values;
- (void)removeMeals:(NSSet<Meal *> *)values;

@end

NS_ASSUME_NONNULL_END

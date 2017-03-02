//
//  WNSyncManager.m
//  Wenu
//
//  Created by Ruslan Kurmakaev on 02/08/16.
//  Copyright © 2016 rkurmakaev. All rights reserved.
//

#import "WNSyncManager.h"
#import "WNHTTPSessionManager.h"
#import "Meal.h"
#import "Category.h"
#import <Photos/Photos.h>

@interface WNSyncManager ()

@property (nonatomic, strong) NSManagedObjectContext *savingContext;
@property (nonatomic, weak) WNHTTPSessionManager *sessionManager;

@end


@implementation WNSyncManager

+ (instancetype)sharedClient {
    
    static WNSyncManager *sharedClient = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        sharedClient = [[WNSyncManager alloc] initPrivate];
    });
    
    return sharedClient;
}

- (instancetype)initPrivate {
    
    if (self = [super init]) {
        
        _savingContext = [NSManagedObjectContext MR_defaultContext];
        _sessionManager = [WNHTTPSessionManager sharedClient];
        
        [self addDefaultCategoriesIfNeeded];
    }
    
    return self;
}

#pragma mark - Public

- (void)saveAllToPersistentStore {
    
    if (![self.savingContext hasChanges]) {
        
        return ;
    }
    
    [self.savingContext MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError * _Nullable error) {
        
        if (contextDidSave) {
            
            [self syncAllData];
        }
    }];
}

- (void)requestMeals:(nullable NSDate *)date withCompletion:(nullable void(^)(void))completion {
    
    [self.sessionManager requestMealsForDate:date
                                     success:^(NSURLSessionDataTask *task, id _Nullable responseObject) {
                                                         
         [self.savingContext MR_saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
             
         NSArray *meals = [Meal MR_importFromArray:responseObject inContext:localContext];
         
         for (Meal *meal in meals) {
             
             NSArray *array = [meal.mealDescirption componentsSeparatedByString:@"#"];
             
             for (int i = 1; i < [array count]; ++i) {
                 
                 NSString *categoryName = [array objectAtIndex:i];
                 
                 categoryName = [categoryName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                 
                 if ([categoryName length] == 0) {
                     
                     continue;
                 }
                 
                 categoryName = [categoryName stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                                                      withString:[[categoryName substringToIndex:1] capitalizedString]];
                 
                 Category *category = [Category MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"%K == %@", CategoryNameDatabaseKey, categoryName] inContext:localContext];
                 
                 if (category == nil) {
                     
                     category = [Category MR_createEntityInContext:localContext];
                     category.name = categoryName;
                 }
                 
                 [meal addCategoriesObject:category];
             }
             
             meal.mealDescirption = array[0];
             
             if ([meal.mealTitle length] == 0) {
                 
                 meal.mealTitle = @"Noname";
             }
         }
     } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
         
         NSLog(@"%@", error);
         
         if (completion)
             completion();
     }];
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
         
         if (completion)
             completion();
     }];
}

- (void)syncMeal:(nonnull NSString *)mealID {
    
    NSPredicate *getMealIfNotSyncedYet = [NSPredicate predicateWithFormat:@"%K == %@ AND %K != 0",
                                                                          MealIDDatabaseKey,
                                                                          mealID,
                                                                          MealSyncstateDatabaseKey];
    
    Meal *meal = [Meal MR_findFirstWithPredicate:getMealIfNotSyncedYet
                                       inContext:self.savingContext];
    
    if (meal == nil)
        return ;
    
    switch ([meal.syncstate integerValue]) {
            
        case WNMealSyncStateNeedToUpload: {
            
            NSDictionary *dict =
                @{MealTitleServerKey : meal.mealTitle,
                  MealDescriptionServerKey : [meal.mealDescirption stringByAppendingString:[meal categoriesToString]],
                  MealDateServerKey : [NSString stringWithFormat:@"%.0lf", [meal.daytime timeIntervalSince1970]],
                  MealPictureServerKey : meal.uploadingPictureURL ?: [NSNull null]};
            
            [self.sessionManager createMeal:dict
                                    success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
            
            if (![responseObject isKindOfClass:[NSDictionary class]]) {
                
                return ;
            }
            
            id stringID = [responseObject objectForKey:@"id"];
            
            if (stringID && [stringID isKindOfClass:[NSString class]]) {
                
                [self.savingContext MR_saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
                   
                    Meal *meal = [Meal MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"%K == %@", MealIDDatabaseKey, mealID]
                                                      inContext:localContext];
                    
                    meal.identifier = stringID;
                    
                    if ([meal.uploadingPictureURL length]) {
                        
                        if ([meal.uploadingPictureURL length]) {
                            
                            meal.pictureURL = [Meal pictureURLFromString:[NSString stringWithFormat:@"%@%.0lf", meal.mealTitle, [meal.daytime timeIntervalSince1970]]];
                            
                            meal.uploadingPictureURL = @"";
                        }
                        meal.uploadingPictureURL = @"";
                    }
                    
                    meal.syncstate = @(WNMealSyncStateSynchronized);
                }];
            }
        }
        failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
            
            NSLog(@"%@", error);
        }];
        }
            break;
            
        case WNMealSyncStateNeedToUpdate: {
            
            NSDictionary *dict = @{MealTitleServerKey : meal.mealTitle,
                                   MealDescriptionServerKey : [meal.mealDescirption stringByAppendingString:[meal categoriesToString]],
                                   MealDateServerKey : [NSString stringWithFormat:@"%.0lf", [meal.daytime timeIntervalSince1970]],
                                   MealPictureServerKey : meal.uploadingPictureURL ?: [NSNull null]};
            
            [self.sessionManager editMeal:meal.identifier
                               parameters:dict
                                  success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
                                                      
              [self.savingContext MR_saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
                  
                  if ([meal.uploadingPictureURL length]) {
                      
                      meal.pictureURL = [Meal pictureURLFromString:[NSString stringWithFormat:@"%@%.0lf", meal.mealTitle, [meal.daytime timeIntervalSince1970]]];

                      meal.uploadingPictureURL = @"";
                  }
                  meal.syncstate = @(WNMealSyncStateSynchronized);
              } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
                  
                  [self.sessionManager requestSpecificMeal:mealID
                                                   success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
                    
                    } failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
                        
                        NSLog(@"%@", error);
                    }];
              }];
          }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
              
              NSLog(@"%@", error);
          }];
        }
            break;
            
        case WNMealSyncStateNeedToDelete: {
            
            [self.sessionManager deleteMeal:meal.identifier
                                    success:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
                
                [self.savingContext MR_saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
                    
                    [meal MR_deleteEntityInContext:localContext];
                }];
            }
            failure:^(NSURLSessionDataTask * _Nullable task, NSError *error) {
                
                NSLog(@"%@", error);
            }];
        }
            break;
            
        default:
            break;
    }
}

- (void)syncAllData {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *mealsToSync =
        [Meal MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"%K != 0", MealSyncstateDatabaseKey]
                            inContext:self.savingContext];
        
        for (Meal *meal in mealsToSync) {
            
            [self syncMeal:meal.identifier];
        }
    });
}

#pragma mark - Private

- (void)addDefaultCategoriesIfNeeded {
    
    if ([Category MR_numberOfEntitiesWithContext:self.savingContext] != 0) {
        
        return ;
    }
    
    [self.savingContext MR_saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        
        NSArray <NSString *> *defaultCategories = @[@"Breakfast",
                                                    @"Lunch",
                                                    @"Brunch",
                                                    @"Dinner",
                                                    @"Supper"];
        
        for (NSString *categoryName in defaultCategories) {
            
            Category *defaultCategory = [Category MR_createEntityInContext:localContext];
            defaultCategory.name = categoryName;
        }
    }];
}

@end

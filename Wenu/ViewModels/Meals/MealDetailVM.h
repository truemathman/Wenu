//
//  MealDetailVM.h
//  Wenu
//
//  Created by Ruslan Kurmakaev on 01/03/17.
//  Copyright © 2017 rkurmakaev. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

@protocol MealDetailCoordinatorVM <NSObject>

@property (nonatomic, copy) void (^editMeal)(NSString *mealID);

@end


@protocol MealDetailVM <NSObject>

@property (nonatomic, copy, readonly) NSString *navigationTitle;

@property (nonatomic, copy, readonly) NSString *mealTitle;
@property (nonatomic, copy, readonly) NSString *dateString;
@property (nonatomic, copy, readonly) NSString *mealDescription;
@property (nonatomic, copy, readonly) NSString *pictureURL;
@property (nonatomic, copy, readonly) NSArray <NSString *> *categories;
@property (nonatomic, assign, readonly) BOOL isSynchronized;

@property (nonatomic, strong, readonly) RACSignal *goBack;

- (void)synchronizeWithServer;
- (void)goToEditingMeal;

@end

NS_ASSUME_NONNULL_END

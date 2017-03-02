//
//  WNSyncManager.h
//  Wenu
//
//  Created by Ruslan Kurmakaev on 02/08/16.
//  Copyright © 2016 rkurmakaev. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

@interface WNSyncManager : NSObject

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)sharedClient;

- (void)saveAllToPersistentStore;

/// request all if date == nil
- (void)requestMeals:(nullable NSDate *)date
      withCompletion:(nullable void(^)(void))completion;

- (void)syncMeal:(NSString *)mealID;
- (void)syncAllData;

@end

NS_ASSUME_NONNULL_END

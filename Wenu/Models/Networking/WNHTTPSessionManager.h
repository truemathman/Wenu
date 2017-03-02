//
//  WNHTTPSessionManager.h
//  Wenu
//
//  Created by Ruslan Kurmakaev on 24/07/16.
//  Copyright © 2016 rkurmakaev. All rights reserved.
//

#import <AFNetworking/AFHTTPSessionManager.h>

NS_ASSUME_NONNULL_BEGIN

@interface WNHTTPSessionManager : AFHTTPSessionManager

+ (instancetype)sharedClient;

- (NSURLSessionDataTask *)createMeal:(NSDictionary *)mealDictionary
                             success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                             failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

- (NSURLSessionDataTask *)editMeal:(NSString *)mealID
                        parameters:(NSDictionary *)mealDictionary
                           success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                           failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

/// If date is nil request all meals
- (NSURLSessionDataTask *)requestMealsForDate:(nullable NSDate *)date
                                      success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                                      failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

- (NSURLSessionDataTask *)requestSpecificMeal:(NSString *)mealID
                                      success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                                      failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

- (NSURLSessionTask *)deleteMeal:(NSString *)mealID
                         success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                         failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

@end

NS_ASSUME_NONNULL_END

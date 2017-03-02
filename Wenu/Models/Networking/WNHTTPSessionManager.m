//
//  WNHTTPSessionManager.m
//  Wenu
//
//  Created by Ruslan Kurmakaev on 24/07/16.
//  Copyright © 2016 rkurmakaev. All rights reserved.
//

#import "WNHTTPSessionManager.h"
#import "Meal.h"
#import "WNSyncManager.h"
#import <Photos/Photos.h>

static NSString * const BaseURLString = @"https://ios.favendo.de/";
static NSString * const ApiKey = @"fca548196c09f9bdf082f0b05e9db1830f50432b83784b1da9522ef8aba8c9fa";

@implementation WNHTTPSessionManager

+ (instancetype)sharedClient {
    
    static WNHTTPSessionManager *sharedClient = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        sharedClient = [[WNHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:BaseURLString]];
    });
    
    return sharedClient;
}

- (instancetype)initWithBaseURL:(NSURL *)url {
    
    if (self = [super initWithBaseURL:url]) {
        
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        [securityPolicy setAllowInvalidCertificates:YES];
        
        self.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
        self.responseSerializer.acceptableContentTypes =
        [NSSet setWithObjects:@"application/json",
         @"text/json",
         @"text/javascript",
         @"text/html", nil];
        
        self.responseSerializer.acceptableContentTypes = [self.responseSerializer.acceptableContentTypes setByAddingObject:@"application/json"];
        
        [self.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
        
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            
            if (status == AFNetworkReachabilityStatusReachableViaWWAN || status == AFNetworkReachabilityStatusReachableViaWiFi) {
                
                [[WNSyncManager sharedClient] syncAllData];
            }
        }];
        
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    }
    
    return self;
}

- (NSURLSessionDataTask *)createMeal:(NSDictionary *)mealDictionary
                             success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                             failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure {
    
    return [self POST:[NSString stringWithFormat:@"meals?api_key=%@", ApiKey]
           parameters:nil
constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    
    NSString *fileName = [Meal pictureURLFromString:[NSString stringWithFormat:@"%@%@", mealDictionary[MealTitleServerKey], mealDictionary[MealDateServerKey]]];
    
    [formData appendPartWithFormData:[mealDictionary[MealTitleServerKey] dataUsingEncoding:NSUTF8StringEncoding]
                                name:MealTitleServerKey];
    
    [formData appendPartWithFormData:[mealDictionary[MealDescriptionServerKey] dataUsingEncoding:NSUTF8StringEncoding]
                                name:MealDescriptionServerKey];
    
    [formData appendPartWithFormData:[mealDictionary[MealDateServerKey] dataUsingEncoding:NSUTF8StringEncoding]
                                name:MealDateServerKey];
    
    if ([mealDictionary[MealPictureServerKey] isEqual:[NSNull null]]) {
        
        [formData appendPartWithFileData:[NSData data]
                                    name:MealPictureServerKey
                                fileName:fileName
                                mimeType:@"image/png"];
    }
    else {
        
        [formData appendPartWithFileData:[WNHTTPSessionManager dataFromImagePath:mealDictionary[MealPictureServerKey]]
                                    name:MealPictureServerKey
                                fileName:fileName
                                mimeType:[WNHTTPSessionManager guessMIMETypeFromFileName:mealDictionary[MealPictureServerKey]]];
    }
}
             progress:nil
              success:success
              failure:failure];
}

- (NSURLSessionDataTask *)editMeal:(NSString *)mealID
                        parameters:(NSDictionary *)mealDictionary
                           success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                           failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure {
    
    return [self POST:[NSString stringWithFormat:@"meals/%@?api_key=%@", mealID, ApiKey]
           parameters:nil
constructingBodyWithBlock:^(id<AFMultipartFormData>  formData) {
    
    NSString *fileName = [Meal pictureURLFromString:[NSString stringWithFormat:@"%@%@", mealDictionary[MealTitleServerKey], mealDictionary[MealDateServerKey]]];

    [formData appendPartWithFormData:[mealDictionary[MealTitleServerKey] dataUsingEncoding:NSUTF8StringEncoding]
                                name:MealTitleServerKey];
    
    [formData appendPartWithFormData:[mealDictionary[MealDescriptionServerKey] dataUsingEncoding:NSUTF8StringEncoding]
                                name:MealDescriptionServerKey];
    
    [formData appendPartWithFormData:[mealDictionary[MealDateServerKey] dataUsingEncoding:NSUTF8StringEncoding]
                                name:MealDateServerKey];
    
    if ([mealDictionary[MealPictureServerKey] isEqual:[NSNull null]]) {
        
        [formData appendPartWithFileData:[NSData data]
                                    name:MealPictureServerKey
                                fileName:fileName
                                mimeType:@"image/png"];
    }
    else {
        
        [formData appendPartWithFileData:[WNHTTPSessionManager dataFromImagePath:mealDictionary[MealPictureServerKey]]
                                    name:MealPictureServerKey
                                fileName:fileName
                                mimeType:[WNHTTPSessionManager guessMIMETypeFromFileName:mealDictionary[MealPictureServerKey]]];
    }
}
             progress:nil
              success:success
              failure:failure];
}


- (NSURLSessionDataTask *)requestMealsForDate:(nullable NSDate *)date
                                      success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                                      failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure {
    
    NSMutableDictionary *parameters = [self defaultParameters];
    
    if (date) {
        
        [parameters setObject:[NSNumber numberWithInteger:[date timeIntervalSince1970]] forKey:MealDateServerKey];
    }
    
    return [self GET:@"meals"
          parameters:parameters
            progress:nil
             success:success
             failure:failure];
}

- (NSURLSessionDataTask *)requestSpecificMeal:(NSString *)mealID
                                      success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                                      failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure {
    
    return [self GET:[NSString stringWithFormat:@"meals/%@", mealID]
          parameters:[self defaultParameters]
            progress:nil
             success:success
             failure:failure];
}

- (NSURLSessionTask *)deleteMeal:(NSString *)mealID
                         success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                         failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure {
    
    return [self DELETE:[NSString stringWithFormat:@"meals/%@?api_key=%@", mealID, ApiKey]
             parameters:nil
                success:success
                failure:failure];
}

- (NSMutableDictionary *)defaultParameters {
    
    return [[NSMutableDictionary alloc] initWithDictionary:@{@"api_key" : ApiKey}];
}

+ (NSString *)guessMIMETypeFromFileName:(NSString *)fileName {
    
    // Borrowed from http://stackoverflow.com/questions/2439020/wheres-the-iphone-mime-type-database
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[fileName pathExtension], NULL);
    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    if (!MIMEType) {
        return @"application/octet-stream";
    }
    return (__bridge_transfer NSString *)(MIMEType);
}

+ (NSData *)dataFromImagePath:(NSString *)imagePath {
    
    __block NSData *data = nil;
    
    PHFetchResult *result = [PHAsset fetchAssetsWithALAssetURLs:@[[NSURL URLWithString:imagePath]]
                                                        options:nil];
    PHAsset *asset = [result firstObject];
    
    PHImageManager *imageManager = [PHImageManager defaultManager];
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.synchronous = YES;
    options.version = PHImageRequestOptionsVersionCurrent;
    
    [imageManager requestImageDataForAsset:asset
                                   options:options
                             resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
        NSLog(@"requestImageDataForAsset returned info(%@)", info);
        data = imageData;
    }];
    
    assert(data.length != 0);
    return data;
}


@end

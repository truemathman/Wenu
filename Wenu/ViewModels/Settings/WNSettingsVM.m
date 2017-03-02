//
//  WNSettingsVM.m
//  Wenu
//
//  Created by Ruslan Kurmakaev on 02/08/16.
//  Copyright © 2016 rkurmakaev. All rights reserved.
//

#import "WNSettingsVM.h"
#import "WNSyncManager.h"

#import <AFNetworking/UIImageView+AFNetworking.h>
#import <AFNetworking/AFImageDownloader.h>

static NSString * const IsFirstDaySundaySettingKey = @"IsFirstDaySundaySettingKey";

@interface WNSettingItemVM : NSObject <SettingsItemVM>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) WNSettingType type;
@property (nonatomic, copy) void (^action)();
@property (nonatomic, strong, nullable) NSObject *initialObject;

@end

@implementation WNSettingItemVM

- (instancetype)initWithTitle:(nonnull NSString *)title type:(WNSettingType)type initialObject:(NSObject *)object andActionBlock:(void (^)(void))action {
    
    if (self = [super init]) {
        
        _title = title;
        _type = type;
        _initialObject = object;
        _action = action;
    }
    
    return self;
}

@end


@interface WNSettingsVM ()

@property (nonatomic, assign) BOOL isSundayFirstWeekday;
@property (nonatomic, copy) NSArray <id <SettingsItemVM> > *dataRows;
@property (nonatomic, weak) WNSyncManager *syncManager;

@end


@implementation WNSettingsVM

- (instancetype)initWithNavigationTitle:(NSString *)navigationTitle
                            syncManager:(WNSyncManager *)syncManager {
    
    if (self = [super initWithNavigationTitle:navigationTitle]) {
        
        _syncManager = syncManager;
        
        NSNumber *isSundayOption = [[NSUserDefaults standardUserDefaults] objectForKey:IsFirstDaySundaySettingKey];
        
        if (isSundayOption == nil) {
            
            _isSundayFirstWeekday = NO;
            [self synchronizeIsFirstSundayOption];
        } else {
            
            _isSundayFirstWeekday = [isSundayOption boolValue];
        }
        
        @weakify(self)
        _dataRows = @[[[WNSettingItemVM alloc] initWithTitle:@"Sunday is first day"
                                                        type:WNSettingTypeSwitch
                                               initialObject:[NSNumber numberWithBool:self.isSundayFirstWeekday]
                                              andActionBlock:^{
            
                        @strongify(self)
                                             
                        if (self == nil)
                            return ;
                         
                        self.isSundayFirstWeekday = !self.isSundayFirstWeekday;
                        [self synchronizeIsFirstSundayOption];
                                                  
                        [[NSNotificationCenter defaultCenter] postNotificationName:WNCalendarFirstWekDayChangedNotification
                                                                            object:nil
                                                                          userInfo:@{WNFirstWeekDayNumberNotification : @(self.isSundayFirstWeekday)}];
                     }],
                     [[WNSettingItemVM alloc] initWithTitle:@"Refresh all data"
                                                   type:WNSettingTypeDefault
                                          initialObject:nil
                                         andActionBlock:^{
                                             
                                             @strongify(self)
                                             
                                             if (self == nil)
                                                 return ;
                                             
                                             [self.syncManager requestMeals:nil withCompletion:nil];
                     }],
                     [[WNSettingItemVM alloc] initWithTitle:@"Synchronize all data"
                                                   type:WNSettingTypeDefault
                                          initialObject:nil
                                         andActionBlock:^{
                         
                         @strongify(self)
                                             
                         if (self == nil)
                             return ;
                         
                         [self syncAllData];
                     }],
                     [[WNSettingItemVM alloc] initWithTitle:@"Clear images cache"
                                                   type:WNSettingTypeDefault
                                          initialObject:nil
                                         andActionBlock:^{
                         
                         @strongify(self)
                                             
                         if (self == nil)
                             return ;
                         
                         [self clearImageCache];
                     }]
                     ];
    }
    
    return self;
}

#pragma mark - Public actions

- (void)clearDatabase {
    
    NSArray *allEntities = [NSManagedObjectModel MR_defaultManagedObjectModel].entities;
    
    [allEntities enumerateObjectsUsingBlock:^(NSEntityDescription *entityDescription, NSUInteger idx, BOOL *stop) {
        
        [NSClassFromString([entityDescription managedObjectClassName]) MR_truncateAll];
    }];
}

- (void)syncAllData {
    
    [self.syncManager syncAllData];
}

- (void)clearImageCache {
    
    [[[UIImageView sharedImageDownloader] imageCache] removeAllImages];
}

- (NSInteger)numberOfSections {
    
    return 1;
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section {
    
    return [self.dataRows count];
}

- (id <SettingsItemVM>)itemForIndexPath:(nonnull NSIndexPath *)indexPath {
    
    return [self.dataRows objectAtIndex:indexPath.row];
}

#pragma mark - Private actions

- (void)synchronizeIsFirstSundayOption {
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:self.isSundayFirstWeekday]
                                              forKey:IsFirstDaySundaySettingKey];
}

@end

//
//  SettingsVM.h
//  Wenu
//
//  Created by Ruslan Kurmakaev on 01/03/17.
//  Copyright © 2017 rkurmakaev. All rights reserved.
//

#import "TableViewVM.h"

typedef NS_ENUM(NSInteger, WNSettingType) {
    
    WNSettingTypeDefault = 0,
    WNSettingTypeSwitch
};

NS_ASSUME_NONNULL_BEGIN

@protocol SettingsItemVM;

@protocol SettingsVM <TableViewVM>

@property (nonatomic, assign, readonly) BOOL isSundayFirstWeekday;

- (void)clearDatabase;
- (void)syncAllData;
- (void)clearImageCache;
- (id <SettingsItemVM>)itemForIndexPath:(NSIndexPath *)indexPath;

@end

@protocol SettingsItemVM <NSObject>

@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, assign, readonly) WNSettingType type;
@property (nonatomic, copy, readonly) void (^action)();
@property (nonatomic, strong, nullable, readonly) NSObject *initialObject;

@end

NS_ASSUME_NONNULL_END

//
//  WNSettingsVM.h
//  Wenu
//
//  Created by Ruslan Kurmakaev on 02/08/16.
//  Copyright © 2016 rkurmakaev. All rights reserved.
//

#import "WNTableViewVM.h"
#import "SettingsVM.h"

NS_ASSUME_NONNULL_BEGIN

@class WNSyncManager;

@interface WNSettingsVM : WNTableViewVM <SettingsVM>

- (instancetype)initWithNavigationTitle:(NSString *)navigationTitle
                            syncManager:(WNSyncManager *)syncManager;

@end

NS_ASSUME_NONNULL_END

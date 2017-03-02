//
//  WNMealSyncState.h
//  Wenu
//
//  Created by Ruslan Kurmakaev on 01/03/17.
//  Copyright © 2017 rkurmakaev. All rights reserved.
//

typedef NS_ENUM(NSInteger, WNMealSyncState) {
    
    WNMealSyncStateSynchronized = 0,
    WNMealSyncStateNeedToUpload,
    WNMealSyncStateNeedToUpdate,
    WNMealSyncStateNeedToDelete
};

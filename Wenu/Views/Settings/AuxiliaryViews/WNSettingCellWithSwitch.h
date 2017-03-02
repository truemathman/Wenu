//
//  SettingCell.h
//  Wenu
//
//  Created by Ruslan Kurmakaev on 02/08/16.
//  Copyright © 2016 rkurmakaev. All rights reserved.
//

#import "WNBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface WNSettingCellWithSwitch : WNBaseCell

@property (nonatomic, copy, nullable) void (^action)(void);

- (instancetype)initWithReusableIdentifier:(NSString *)reuseIdentifier withSwitch:(BOOL)useSwitch;

- (void)setSwitchState:(BOOL)isOn;

@end

NS_ASSUME_NONNULL_END

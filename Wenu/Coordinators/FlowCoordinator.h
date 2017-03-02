//
//  FlowCoordinator.h
//  Wenu
//
//  Created by Ruslan Kurmakaev on 01/03/17.
//  Copyright © 2017 rkurmakaev. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

@protocol FlowCoordinator <NSObject>

- (void)startWithNavigationController:(UINavigationController *)navigationController;

@end

NS_ASSUME_NONNULL_END

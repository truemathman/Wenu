//
//  BaseFlowCoordinator.h
//  Wenu
//
//  Created by Ruslan Kurmakaev on 01/03/17.
//  Copyright © 2017 rkurmakaev. All rights reserved.
//

#import "FlowCoordinator.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ViewModelsFactory;

@interface BaseFlowCoordinator : NSObject <FlowCoordinator>

@property (nonatomic, weak, readonly) id <ViewModelsFactory> viewModelsFactory;

- (instancetype)initWithViewModelsFactory:(id <ViewModelsFactory>)viewModelsFactory;

@end

NS_ASSUME_NONNULL_END

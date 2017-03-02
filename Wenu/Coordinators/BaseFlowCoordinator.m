//
//  BaseFlowCoordinator.m
//  Wenu
//
//  Created by Ruslan Kurmakaev on 01/03/17.
//  Copyright © 2017 rkurmakaev. All rights reserved.
//

#import "BaseFlowCoordinator.h"
#import "ViewModelsFactory.h"

@interface BaseFlowCoordinator ()

@property (nonatomic, weak) id <ViewModelsFactory> viewModelsFactory;

@end

@implementation BaseFlowCoordinator

- (instancetype)initWithViewModelsFactory:(id <ViewModelsFactory>)viewModelsFactory {
    
    self = [super init];
    
    if (self) {
        
        _viewModelsFactory = viewModelsFactory;
    }
    
    return self;
}

@end

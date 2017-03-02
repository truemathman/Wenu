//
//  WNTableViewVM.m
//  Wenu
//
//  Created by Ruslan Kurmakaev on 01/03/17.
//  Copyright © 2017 rkurmakaev. All rights reserved.
//

#import "WNTableViewVM.h"

@interface WNTableViewVM ()

@property (nonatomic, strong) RACSignal *willChangeContentSignal;
@property (nonatomic, strong) RACSignal *itemChangeSignal;
@property (nonatomic, strong) RACSignal *sectionChangeSignal;
@property (nonatomic, strong) RACSignal *didChangeContentSignal;

@property (nonatomic, strong) RACSignal *reloadData;
@property (nonatomic, strong) RACSignal *refreshingStarted;
@property (nonatomic, strong) RACSignal *refreshingFinished;

@property (nonatomic, copy) NSString *navigationTitle;

@end


@implementation WNTableViewVM

- (instancetype)initWithNavigationTitle:(nonnull NSString *)navigationTitle {
    
    if (self = [super init]) {
        
        _navigationTitle = navigationTitle;
        
        /// Initialize RAC signals
        _willChangeContentSignal =
            [[RACSubject subject] setNameWithFormat:@"%@ willChangeContentSignal", NSStringFromClass([self class])];
        _itemChangeSignal =
            [[RACSubject subject] setNameWithFormat:@"%@ itemChangeSignal", NSStringFromClass([self class])];
        _sectionChangeSignal =
            [[RACSubject subject] setNameWithFormat:@"%@ sectionChangeSignal", NSStringFromClass([self class])];
        _didChangeContentSignal =
            [[RACSubject subject] setNameWithFormat:@"%@ didChangeContentSignal", NSStringFromClass([self class])];
        
        _reloadData =
            [[RACSubject subject] setNameWithFormat:@"%@ reloadData", NSStringFromClass([self class])];
        
        _refreshingStarted =
            [[RACSubject subject] setNameWithFormat:@"%@ refreshingStarted", NSStringFromClass([self class])];
        _refreshingFinished =
            [[RACSubject subject] setNameWithFormat:@"%@ refreshingFinished", NSStringFromClass([self class])];
    }
    
    return self;
}

- (void)dealloc {
    
}

@end

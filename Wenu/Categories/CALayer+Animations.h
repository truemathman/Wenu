//
//  CALayer+Animations.h
//  NavigationSystem_iOS_UI
//
//  Created by Ruslan Kurmakayev on 10/04/2014.
//  Copyright (c) 2014 Navmii. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CALayer (WNAnimations)

- (void)WN_addFadeAnimationWithDuration:(NSTimeInterval)duration;
- (void)WN_addTransitionFlip:(BOOL)fromLeft;
- (void)WN_addPushAnimationWithDirection:(NSString *)type duration:(NSTimeInterval)duration;
- (void)WN_addPushAnimationWithDirection:(NSString *)type duration:(NSTimeInterval)duration delegate:(id)delegate;
- (void)WN_addFadeAnimationWithDuration:(NSTimeInterval)duration completion:(void (^)(void))completionBlock;
- (void)WN_addFadeAnimationWithDuration:(NSTimeInterval)duration key:(NSString *)key completion:(void (^)(void))completionBlock;

- (void)WN_addScaleAnimationFromValue:(CGFloat)from
                           toValue:(CGFloat)to
                          duration:(NSTimeInterval)duration
                             delay:(NSTimeInterval)delay
                        completion:(void (^)(void))completionBlock;

- (void)WN_addScaleAnimationToValue:(CGFloat)to
                        duration:(NSTimeInterval)duration
                           delay:(NSTimeInterval)delay
                      completion:(void (^)(void))completionBlock;

- (void)WN_addScaleAnimationWithValues:(NSArray *)values
                           keyTimes:(NSArray *)keyTimes
                           duration:(NSTimeInterval)duration
                              delay:(NSTimeInterval)delay
                         completion:(void (^)(void))completionBlock;

- (void)WN_addTapAnimationWithDuration:(NSTimeInterval)duration withDelay:(NSTimeInterval)delay;

@end


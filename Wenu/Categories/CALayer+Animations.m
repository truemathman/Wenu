//
//  CALayer+Animations.m
//  NavigationSystem_iOS_UI
//
//  Created by Ruslan Kurmakayev on 10/04/2014.
//  Copyright (c) 2014 Navmii. All rights reserved.
//

#import "CALayer+Animations.h"
#import <UIKit/UIKit.h>

@implementation CALayer (WNAnimations)

- (void)WN_addFadeAnimationWithDuration:(NSTimeInterval)duration completion:(void (^)(void))completionBlock
{    
    [self WN_addFadeAnimationWithDuration:duration
                                      key:nil
                               completion:completionBlock];
}

- (void)WN_addFadeAnimationWithDuration:(NSTimeInterval)duration
                                 key:(NSString *)key
                          completion:(void (^)(void))completionBlock
{
    [CATransaction begin];
    if(completionBlock)
        [CATransaction setCompletionBlock:completionBlock];
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = duration;
    [self addAnimation:animation forKey:key];
    [CATransaction commit];
}

- (void)WN_addFadeAnimationWithDuration:(NSTimeInterval)duration
{
	CATransition *animation = [CATransition animation];
	animation.type = kCATransitionFade;
	animation.duration = duration;
	[self addAnimation:animation forKey:nil];
}

- (void)WN_addTransitionFlip:(BOOL)fromLeft
{
    UIView *view = [UIView new];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.75];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationTransition:(fromLeft ? UIViewAnimationTransitionFlipFromLeft : UIViewAnimationTransitionFlipFromRight) forView:view cache:YES];
    [view removeFromSuperview];
    [UIView commitAnimations];
    
    CAAnimation *animation = nil;
    if ([view.layer animationKeys].count)
    {
        NSString *animationKey = [[view.layer animationKeys] objectAtIndex:0];
        animation = [view.layer animationForKey:animationKey];
    }
    
    [self addAnimation:(animation ? animation : [CATransition animation]) forKey:nil];
}

- (void)WN_addPushAnimationWithDirection:(NSString *)type duration:(NSTimeInterval)duration
{
	CATransition *animation = [CATransition animation];
	animation.type = kCATransitionPush;
	animation.subtype = type;
	animation.duration = duration;
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	[self addAnimation:animation forKey:nil];
}

- (void)WN_addPushAnimationWithDirection:(NSString *)type duration:(NSTimeInterval)duration delegate:(id)delegate
{
	CATransition *animation = [CATransition animation];
	animation.type = kCATransitionPush;
	animation.subtype = type;
	animation.duration = duration;
    animation.delegate = delegate;
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	[self addAnimation:animation forKey:nil];
}

- (void)WN_addTapAnimationWithDuration:(NSNumber *)duration {
    
    NSTimeInterval dur = duration.doubleValue;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale.xy"];
    animation.fromValue = @(1.0);
    animation.toValue = @(0.75);
    animation.duration = dur;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.removedOnCompletion = YES;
    animation.fillMode = kCAFillModeBackwards;
    [self addAnimation:animation forKey:@"JumpScale"];
}

- (void)WN_addScaleAnimationFromValue:(CGFloat)from
                           toValue:(CGFloat)to
                          duration:(NSTimeInterval)duration
                             delay:(NSTimeInterval)delay
                        completion:(void (^)(void))completionBlock {
    
    [self removeAnimationForKey:@"scale"];
    
    [CATransaction begin];
    if(completionBlock)
        [CATransaction setCompletionBlock:completionBlock];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale.xy"];
    animation.fromValue = @(from);
    animation.toValue = @(to);
    animation.duration = duration;
    animation.beginTime = CACurrentMediaTime() + delay;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.removedOnCompletion = NO;
    animation.fillMode = (delay == 0 ? kCAFillModeForwards : kCAFillModeBoth);
    [self addAnimation:animation forKey:@"scale"];
    [CATransaction commit];
}

- (void)WN_addScaleAnimationToValue:(CGFloat)to
                        duration:(NSTimeInterval)duration
                           delay:(NSTimeInterval)delay
                      completion:(void (^)(void))completionBlock {
    
    [self removeAnimationForKey:@"scale"];
    
    [CATransaction begin];
    if(completionBlock)
        [CATransaction setCompletionBlock:completionBlock];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale.xy"];
    animation.toValue = @(to);
    animation.duration = duration;
    animation.beginTime = CACurrentMediaTime() + delay;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.removedOnCompletion = NO;
    animation.fillMode = (delay == 0 ? kCAFillModeForwards : kCAFillModeBoth);
    [self addAnimation:animation forKey:@"scale"];
    [CATransaction commit];
}

- (void)WN_addScaleAnimationWithValues:(NSArray *)values
                           keyTimes:(NSArray *)keyTimes
                           duration:(NSTimeInterval)duration
                              delay:(NSTimeInterval)delay
                         completion:(void (^)(void))completionBlock {
    
    [self removeAnimationForKey:@"scale"];
    
    if ([values count] > 0) {
    
        NSNumber *initialValue = values.firstObject;
        
        self.transform = CATransform3DMakeScale(initialValue.floatValue, initialValue.floatValue, 1);
    }

    [CATransaction begin];
    if(completionBlock)
        [CATransaction setCompletionBlock:completionBlock];
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale.xy"];
    animation.values = values;
    animation.keyTimes = keyTimes;
    animation.duration = duration;
    animation.beginTime = CACurrentMediaTime() + delay;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.removedOnCompletion = NO;
    animation.fillMode = (delay == 0 ? kCAFillModeForwards : kCAFillModeBoth);
    [self addAnimation:animation forKey:@"scale"];
    [CATransaction commit];
}

- (void)WN_addTapAnimationWithDuration:(NSTimeInterval)duration withDelay:(NSTimeInterval)delay {
    
    [self performSelector:@selector(WN_addTapAnimationWithDuration:) withObject:@(duration) afterDelay:delay];
}

@end


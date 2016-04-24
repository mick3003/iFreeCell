//
//  FCAnimatedTransitioning.m
//  iFreeCell
//
//  Created by Miguel Estévez on 29/3/16.
//  Copyright © 2016 Miguel Estévez. All rights reserved.
//

#import "FCAnimatedTransitioning.h"

@implementation FCAnimatedTransitioning

- (NSTimeInterval) transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    CGFloat ret = .5F;
    if( !self.isPresenting )
    {
        ret  = .8F;
    }
    return ret;
}

- (void) animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *fromView = fromVC.view;
    UIView *toView = toVC.view;
    
    UIView *containerView = [transitionContext containerView];
    
    if( self.isPresenting )
    {
        [containerView addSubview:toView];
    }
    
    UIViewController *animatingVC = self.isPresenting ? toVC : fromVC;
    UIView *animatingView = animatingVC.view;
    
    CGRect finalFrameForVC = [transitionContext finalFrameForViewController:animatingVC];
    CGRect initialFrameForVC = finalFrameForVC;
    
    if( self.isPresenting )
        // initialFrameForVC.origin.y = initialFrameForVC.size.height;
        initialFrameForVC.origin.x = initialFrameForVC.size.width;
    else
        // initialFrameForVC.origin.y = -initialFrameForVC.size.height;
        initialFrameForVC.origin.x = -initialFrameForVC.size.width;
    
    CGRect initialFrame = self.isPresenting ? initialFrameForVC : finalFrameForVC;
    CGRect finalFrame = self.isPresenting ? finalFrameForVC : initialFrameForVC;
    
    animatingView.frame = initialFrame;
    
    NSTimeInterval transDuration = [self transitionDuration:transitionContext];
    
    [UIView animateWithDuration:transDuration delay:0 usingSpringWithDamping:300.F initialSpringVelocity:2.F options:UIViewAnimationOptionCurveEaseOut
                     animations:^
     {
         animatingView.frame = finalFrame;
     }
                     completion:^(BOOL finished)
     {
         if( finished )
         {
             if( !self.isPresenting )
             {
                 [fromView removeFromSuperview];
             }
             [transitionContext completeTransition:YES];
         }
     }];
}

@end

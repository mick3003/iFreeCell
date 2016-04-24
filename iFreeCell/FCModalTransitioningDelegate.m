//
//  FCModalTransitioningDelegate.m
//  iFreeCell
//
//  Created by Miguel Estévez on 29/3/16.
//  Copyright © 2016 Miguel Estévez. All rights reserved.
//

#import "FCModalTransitioningDelegate.h"
#import "FCPresentationController.h"
#import "FCAnimatedTransitioning.h"

@implementation FCModalTransitioningDelegate 

- (UIPresentationController *) presentationControllerForPresentedViewController:(UIViewController *)presented
                                                       presentingViewController:(UIViewController *)presenting
                                                           sourceViewController:(UIViewController *)source
{
    return [[FCPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                   presentingController:(UIViewController *)presenting
                                                                       sourceController:(UIViewController *)source
{
    id <UIViewControllerAnimatedTransitioning> animationController = [FCAnimatedTransitioning new];
    [(FCAnimatedTransitioning *)animationController setIsPresenting:YES];
    
    return animationController;
}

- (id <UIViewControllerAnimatedTransitioning>) animationControllerForDismissedController:(UIViewController *)dismissed
{
    id <UIViewControllerAnimatedTransitioning> animationController = [FCAnimatedTransitioning new];
    
    [(FCAnimatedTransitioning *)animationController setIsPresenting:NO];
    
    return animationController;
}


@end

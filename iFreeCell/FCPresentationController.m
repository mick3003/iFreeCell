//
//  FCPresentationController.m
//  iFreeCell
//
//  Created by Miguel Estévez on 29/3/16.
//  Copyright © 2016 Miguel Estévez. All rights reserved.
//

#import "FCPresentationController.h"

#define kMaxAlpha   1.F

@implementation FCPresentationController

- (id) initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController
{
    if( self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController] )
    {
        UIVisualEffect *visualEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        self.chromeView = [[UIVisualEffectView alloc] initWithEffect:visualEffect];
        self.chromeView.alpha = 0.F;
    }
    return self;
}

- (CGRect) frameOfPresentedViewInContainerView
{
    CGRect presentedViewFrame = CGRectZero;
    CGRect containerBounds = self.containerView.bounds;
    
    presentedViewFrame.size = [self sizeForChildContentContainer:self.presentedViewController withParentContainerSize:containerBounds.size];
    presentedViewFrame.origin.x = containerBounds.size.width - presentedViewFrame.size.width;
    
    return presentedViewFrame;
}

- (void) presentationTransitionWillBegin
{
    self.chromeView.frame = self.containerView.bounds;
    self.chromeView.alpha = 0.F;
    [self.containerView insertSubview:self.chromeView atIndex:0];
    
    id coordinator = self.presentedViewController.transitionCoordinator;
    
    if( coordinator != nil )
    {
        [coordinator animateAlongsideTransition:^(id <UIViewControllerTransitionCoordinatorContext> context)
         {
             self.chromeView.alpha = kMaxAlpha;
         }
         completion:NULL];
    }
    else
    {
        self.chromeView.alpha = kMaxAlpha;
    }
}

- (void) dismissalTransitionWillBegin
{
    id coordinator = self.presentedViewController.transitionCoordinator;
    
    if( coordinator != nil )
    {
        [coordinator animateAlongsideTransition:^(id <UIViewControllerTransitionCoordinatorContext> context)
         {
             self.chromeView.alpha = .0F;
         }
         completion:NULL];
    }
    else
    {
        self.chromeView.alpha = .0F;
    }
}

- (void) containerViewWillLayoutSubviews
{
    self.chromeView.frame = self.containerView.bounds;
    self.presentedView.frame = self.frameOfPresentedViewInContainerView;
}

- (BOOL) shouldPresentInFullscreen
{
    return YES;
}

- (UIModalPresentationStyle) adaptivePresentationStyle
{
    return UIModalPresentationFullScreen;
}

@end

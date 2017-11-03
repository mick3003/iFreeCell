//
//  FCViewController.m
//  iFreeCell
//
//  Created by Miguel Estévez on 03/08/16.
//  Copyright (c) 2013 Miguel Estévez. All rights reserved.
//

#import "FCViewController.h"
#import "FCGameScene.h"
#import "FCModalTransitioningDelegate.h"
#import "FCCardDetailViewController.h"
#import "FCCard.h"
#import "FCAlertViewController.h"
#import "FCGameScene+MainMenu.h"

@interface FCViewController () <FCModalPresentationDelegate, FCAlertViewControllerDelegate>
{
}

@property (nonatomic, weak) FCGameScene * gameScene;
@property (nonatomic, weak) IBOutlet UIButton *popoverButton;
@property (nonatomic, strong) NSDictionary *userInfo;

@property (nonatomic, strong) FCModalTransitioningDelegate *modalTransitioningDelegate;

@end


@implementation FCViewController

- (UIStatusBarStyle) preferredStatusBarStyle
{
    // NSLog(@"%s", __FUNCTION__);
    return UIStatusBarStyleLightContent;
}

- (void) viewDidLoad
{
    [super viewDidLoad];

    self.modalTransitioningDelegate = [FCModalTransitioningDelegate new];
    
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    
    skView.multipleTouchEnabled = YES;
    
//    CGRect f = [[[UIApplication sharedApplication] windows][0] bounds];
//    f = CGRectMake(0, 0, 1334, 750);
//    skView.frame = f;
    
    BOOL flag = NO;
#ifdef DEBUG
    flag = YES;
#endif
    skView.showsFPS = flag;
    skView.showsNodeCount = flag;
    skView.showsDrawCount = flag;
    
    // Create and configure the scene.
    self.gameScene = [FCGameScene sceneWithSize:skView.bounds.size];
    self.gameScene.scaleMode = SKSceneScaleModeAspectFill;
    self.gameScene.presentationDelegate = self;
    
    // Present the scene.
    [skView presentScene:self.gameScene];
}

- (BOOL) shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape; 
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - Presentation delegate

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController *vc = segue.destinationViewController;
    
    self.transitioningDelegate = self.modalTransitioningDelegate;
    vc.transitioningDelegate = self.transitioningDelegate;
    
    if( [segue.identifier isEqualToString:@"CardDetailSegueId"] )
    {
        FCCardDetailViewController *detailVC = (FCCardDetailViewController *) vc;
        id detailTarget = self.userInfo[@"target"];
        
        detailVC.showingZPosition = [self.userInfo[@"previousZ"] floatValue];
        
        if( [detailTarget isKindOfClass:[FCCard class]] )
        {
            detailVC.card = detailTarget;
        }
        else if( [detailTarget isKindOfClass:[FCSlot class]] )
        {
            detailVC.slot = detailTarget;
        }
    }
    else if( [segue.identifier isEqualToString:@"GameToAlertSegue"] )
    {
        FCAlertViewController *alertViewController = segue.destinationViewController;
        alertViewController.message = @"You are about to reset the game board. This operation can not be undone. Are you sure?";
        alertViewController.buttonTitles = @[@"YES", @"NO"];
        alertViewController.delegate = self;
    }
}

- (void) shouldPresentModalForAction:(FCModalAction)action userInfo:(NSDictionary *)userInfo
{
    switch( action )
    {
        case FCModalActionNewGame:
            [self performSegueWithIdentifier:@"SegueOne" sender:self];
            break;
        case FCModalActionReset:
            [self performSegueWithIdentifier:@"GameToAlertSegue" sender:self];
            break;
        case FCModalActionCartDetail:
            self.userInfo = userInfo;
            [self openCartDetailOnPoint:[userInfo[@"location"] CGPointValue]];
            break;
        case FCModalActionGameSolved:
            [self showGameSolvedAlert];
        default:
            ;
            break;
    };
}

- (void) openCartDetailOnPoint:(CGPoint)point
{
    CGRect popoverButtonFrame = CGRectMake(point.x, point.y, 4.F, 4.F);
    
    self.popoverButton.frame = popoverButtonFrame;
    
    [self performSegueWithIdentifier:@"CardDetailSegueId" sender:self];
}

- (void) showGameSolvedAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"iFreeCell" message:@"GAME SOLVED!!" preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:YES completion:NULL];
}


#pragma mark - FCAlertViewControllerDelegate

- (void) alertViewController:(FCAlertViewController *)alertViewController tappedButtonAtIndex:(NSInteger)index
{
    NSLog(@"%s :: %@", __FUNCTION__, @(index));
    
    if( index == 0 )
    {
        [self.gameScene resetMenuOption];
    }
}

@end

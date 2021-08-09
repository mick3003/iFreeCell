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
#import "FCNewGameViewController.h"
#import "FCMiscViewController.h"

@interface FCViewController () < FCModalPresentationDelegate,
                                 FCAlertViewControllerDelegate,
                                 FCNewGameControllerDelegate,
                                 FCMiscViewControllerDelegate >
{
}

@property (nonatomic, strong) FCGameScene * gameScene;
@property (nonatomic, weak) IBOutlet UIButton *popoverButton;
@property (nonatomic, strong) NSDictionary *userInfo;

@property (nonatomic, weak) IBOutlet SKView *skView;
@property (nonatomic, weak) IBOutlet UILabel *gameNumberLabel;

@property (nonatomic, strong) FCModalTransitioningDelegate *modalTransitioningDelegate;

@end


@implementation FCViewController

- (BOOL) prefersStatusBarHidden
{
    return YES;
}

- (UIStatusBarStyle) preferredStatusBarStyle
{
    // NSLog(@"%s", __FUNCTION__);
    return UIStatusBarStyleLightContent;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
    NSString *documentPath = [paths objectAtIndex:0];
    NSURL *url = [NSURL fileURLWithPath:documentPath];
    NSLog(@"Documents path:'%@'", url.absoluteString);

    self.modalTransitioningDelegate = [FCModalTransitioningDelegate new];
    
    // Configure the view.
    SKView * skView = (SKView *)self.skView;
    
    skView.multipleTouchEnabled = NO;
    
    BOOL flag = NO;
#ifdef DEBUG
    flag = YES;
#endif
    skView.showsFPS = flag;
    skView.showsNodeCount = flag;
    skView.showsDrawCount = flag;
    skView.ignoresSiblingOrder = YES;
    
    NSInteger gameNumber = FCGameState.shared.gameNumber;
    
    if( gameNumber == 0)
    {
        // TODO assign a random number
        gameNumber = 2;
    }
    
    [self drawGameNumber:gameNumber];
    
    // Create and configure the scene.
    self.gameScene = [FCGameScene sceneWithSize:skView.bounds.size gameNumber:gameNumber];
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

- (IBAction) menuButtonTapped:(UIButton *)sender
{
    [self.gameScene toggleMenu];
}


#pragma mark - Presentation delegate

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(SegueObject *)sender
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
        
        alertViewController.modalAction = sender.modalAction;
        alertViewController.message = sender.message;
        alertViewController.buttonTitles = sender.buttonsArray;
        alertViewController.delegate = self;
    }
    else if( [segue.identifier isEqualToString:@"NewGameSegue"] )
    {
        FCNewGameViewController *newGameViewController = segue.destinationViewController;
        newGameViewController.delegate = self;
    }
    else if( [segue.identifier isEqualToString:@"MiscToAlertSegue"] )
    {
        FCMiscViewController *miscViewController = segue.destinationViewController;
        miscViewController.delegate = self;
    }
}

- (void) shouldPresentModalForAction:(FCModalAction)action userInfo:(NSDictionary *)userInfo
{
    SegueObject *segueObject = [SegueObject new];
    
    switch( action )
    {
        case FCModalActionNewGame:
            [self performSegueWithIdentifier:@"NewGameSegue" sender:self];
            break;
        case FCModalActionReset:
            segueObject.modalAction = FCModalActionReset;
            segueObject.message = @"You are about to reset the game board. This operation can not be undone.\nAre you sure?";
            segueObject.buttonsArray = @[@"YES", @"NO"];
            [self performSegueWithIdentifier:@"GameToAlertSegue" sender:segueObject];
            break;
        case FCModalActionCartDetail:
            self.userInfo = userInfo;
            [self openCartDetailOnPoint:[userInfo[@"location"] CGPointValue]];
            break;
        case FCModalActionGameSolved:
            segueObject.modalAction = FCModalActionGameSolved;
            segueObject.message =
                [NSString stringWithFormat:@"You win!!\nDo you want to play another game?\n%@", [self getStatisticsString]];
            segueObject.buttonsArray = @[@"NEW GAME"];
            [self performSegueWithIdentifier:@"GameToAlertSegue" sender:segueObject];
            break;
        case FCModalActionMisc:
            [self performSegueWithIdentifier:@"MiscToAlertSegue" sender:nil];
            break;;
        default:
            ;
            break;
    };
}

- (void) drawGameNumber:(NSInteger)gameNumber
{
    self.gameNumberLabel.text = [NSString stringWithFormat:@"Game # %05ld", gameNumber];
}

- (NSString *) getStatisticsString
{
    CGFloat playedGames = [[FCGameState shared] getNumberOfPlayedGames];
    CGFloat wonGames = [[FCGameState shared] getNumberOfWins];
    NSInteger perc = wonGames / playedGames * 100.0F;
    
    return [NSString stringWithFormat:@"Games won: %.0f/%.0f (%ld%%)", wonGames, playedGames, perc];
}

- (void) openCartDetailOnPoint:(CGPoint)point
{
    CGRect popoverButtonFrame = CGRectMake(point.x, point.y, 4.F, 4.F);
    
    self.popoverButton.frame = popoverButtonFrame;
    
    [self performSegueWithIdentifier:@"CardDetailSegueId" sender:self];
}


#pragma mark - FCAlertViewControllerDelegate

- (void) alertViewController:(FCAlertViewController *)alertViewController tappedButtonAtIndex:(NSInteger)index
{
    NSLog(@"%s :: %@", __FUNCTION__, @(index));
    if( alertViewController.modalAction == FCModalActionReset )
    {
        if( index == 0 )
        {
            [self.gameScene resetMenuOption];
        }
    }
    else if( alertViewController.modalAction == FCModalActionGameSolved )
    {
        NSInteger gameNumber = [FCHelper randomGameNumber];
        [self drawGameNumber:gameNumber];
        [self.gameScene newGameMenuOption:gameNumber];
    }
}


#pragma mark - FCNewGameController delegate

- (void) newGameViewController:(FCNewGameViewController *)newGameViewController finishWithGameNumber:(NSInteger)gameNumber
{
    NSLog(@"%s", __FUNCTION__);
    [self drawGameNumber:gameNumber];
    [self.gameScene newGameMenuOption:gameNumber];
}

- (void) newGameViewControllerDidOpen:(FCNewGameViewController *)newGameViewController
{
    [self.gameScene menuOpen:NO];
}

- (void) newGameViewControllerWillClose:(FCNewGameViewController *)newGameViewController
{
    [self.gameScene menuOpen:NO];
}


#pragma mark - FCMiscGameController delegate

- (void) miscViewControllerDidOpen:(FCMiscViewController *)miscViewController
{
    [self.gameScene menuOpen:NO];
}

- (void) miscViewController:(FCMiscViewController *)miscViewController tappedButtonAtIndex:(NSInteger)index
{
    NSLog(@"%s", __FUNCTION__);
}

@end

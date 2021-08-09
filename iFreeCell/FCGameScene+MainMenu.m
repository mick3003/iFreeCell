//
//  FCGameScene+MainMenu.m
//  iFreeCell
//
//  Created by Miguel Estévez on 01/06/14.
//  Copyright (c) 2014 Miguel Estévez. All rights reserved.
//

#import "FCGameScene+MainMenu.h"
#import "FCGameState.h"
#import "FCCard.h"
#import "FCSlot.h"

#define kMenuMaxX   270.F

@interface FCGameScene ()
- (void) prepareContent;
@end

@implementation FCGameScene (MainMenu)

- (void) moveMenuWithDeltaPoint:(CGPoint) deltaPoint
{
    /*
    CGFloat newX = gameLayer.position.x + deltaPoint.x;
    
    // NSLog(@"-- deltaPoint = %@ -- newX = %f", NSStringFromCGPoint(deltaPoint), newX);
    
    _menuMoveDelta = deltaPoint.x;
    
    if( newX < 0.F ) newX = 0.F;
    if( newX > kMenuMaxX ) newX = kMenuMaxX;
    
    gameLayer.position = CGPointMake(newX, gameLayer.position.y);
    _menuDragging = YES;
     */
}

- (void) moveMenuTouchEnded:(CGPoint) touchLocation
{
    /*
    CGPoint point;
    
    if( _menuMoveDelta > 0 )
    {
        point = CGPointMake(kMenuMaxX, 0.F);
        _menuShowing = YES;
    }
    else
    {
        point = CGPointZero;
        _menuShowing = NO;
    }
    
    if( !_doubleSwipeDetected )
    {
        if( !_menuDragging ) point = CGPointZero;
    }
    
    SKAction *move = [SKAction moveTo:point duration:.25];
    move.timingMode = SKActionTimingEaseOut;
    
    [gameLayer runAction:move completion:^{}];
    
    _menuDragging = NO;
     */
}

- (void) toggleMenu
{
    [self menuOpen:!self.menuShowing];
}

- (void) menuOpen:(BOOL)open
{
    CGPoint point = CGPointZero;
    if( open ) point = CGPointMake(kMenuMaxX, 0.F);
    
    SKAction *menuMove = [SKAction moveTo:point duration:.25];
    menuMove.timingMode = SKActionTimingEaseOut;
    [gameLayer runAction:menuMove completion:^{
        self.menuShowing = open;
    }];
}

- (void) resetMenuOption
{
    [[FCGameState shared] resetState];
    [[FCGameState shared] addGameToStatistics];
    [self prepareContent];
}

- (void) undoMenuOption
{
    FCMove *lastMove = [[FCGameState shared] consumLastMove];

    lastMove.target.zPosition = kZPositionMove;
    
    if( [lastMove.previousParent isKindOfClass:[FCCard class]] )
    {
        [lastMove.target becomeChildOfCard:(FCCard *) lastMove.previousParent fromUndo:YES];
    }
    else
    {
        [lastMove.target becomeChildOfSlot:(FCSlot *) lastMove.previousParent fromUndo:YES];
    }
}

- (void) newGameMenuOption:(NSInteger) gameNumber
{
    [FCGameState shared].gameNumber = gameNumber;
    [[FCGameState shared] resetState];
    [self prepareContent];
    self.paused = NO;
}

@end

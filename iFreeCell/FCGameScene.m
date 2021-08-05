//
//  FCMyScene.m
//  iFreeCell
//
//  Created by Miguel Estévez on 03/08/16.
//  Copyright (c) 2013 Miguel Estévez. All rights reserved.
//

#import "FCGameScene.h"
#import "FCGameScene+MainMenu.h"
#import "NSMutableArray+ContactNodes.h"
#import "FCBoardHelper.h"
#import "FCCard.h"
#import "FCPoint.h"
#import "FCSlot.h"
#import "FCMenuScene.h"

#define kLongPressTime  .5F

@interface FCGameScene () <SKPhysicsContactDelegate, FCMainMenuDelegate, FCCardMoveEndedDelegate>
{
    FCMenuScene *_menuScene;
    
    CGFloat _longTouchTime;
    CGPoint _longTouchBeganPoint;
    BOOL _longTouchTriggered;
    BOOL _autoStackMoving;
    BOOL _autoMovingCard;
    
    CGFloat _previousZPosition;
    
    SKSpriteNode *_touchNode;
    
    CGFloat _yDelta, _yDeltaCards;
}

@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;

@end


@implementation FCGameScene

+ (instancetype) sceneWithSize:(CGSize)size gameNumber:(NSInteger)gameNumber
{
    FCGameScene *gameScene = [[FCGameScene alloc] initWithSize:size gameNumber:(NSInteger)gameNumber];
    FCGameState.shared.gameNumber = gameNumber;
    return gameScene;
}

- (id) initWithSize:(CGSize)size gameNumber:(NSInteger)gameNumber
{
    if (self = [super initWithSize:size])
    {
        FCGameState.shared.gameNumber = gameNumber;
        gameLayer = [SKNode node];
        gameLayer.position = CGPointZero;
        gameLayer.zPosition = kZPositionGameLayer;
        
        _contactNodes = [NSMutableArray new];
        
        [self addChild:gameLayer];
        
        _screenSize = size;
        _mainScale = .65F;
        BOOL rounded = [FCHelper isRoundedDisplay];
        _yDelta = 120 + (rounded ? 22.F : 0.0F);
        _yDeltaCards = 282 + (rounded ? 23.F : 0.F);
        
        self.backgroundColor = [SKColor colorWithRed:.14 green:.22 blue:.3 alpha:1.0];
        
        self.physicsWorld.gravity = CGVectorMake(0.F, 0.F);
        self.physicsWorld.contactDelegate = self;
        
        _menuScene = [[FCMenuScene alloc] init];
        _menuScene.delegate = self;
        self.menuShowing = NO;
        
        [self addChild:_menuScene];
        
        [self prepareContent];
    }
    
    return self;
}


#pragma mark - Prepare content

- (void) prepareContent
{
    [self menuOpen:NO];
    
    // _background = [SKSpriteNode spriteNodeWithImageNamed:@"beach"];
    
    if( !_background )
    {
        CGSize bgndSize = CGSizeMake(self.frame.size.width * 2.F, self.frame.size.height * 2.F);
        _background = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithRed:30.F/255.F green:153.F/255.F blue:199.F/255.F alpha:1.F] size:bgndSize];
        _background.anchorPoint = CGPointZero;
        _background.position = CGPointZero;
        
        [gameLayer addChild:_background];
    }
    /*
    else
    {
        CGSize bgndSize = CGSizeMake(self.frame.size.width , self.frame.size.height );
        _background.size = bgndSize;
        _background.anchorPoint = CGPointZero;
        _background.position = CGPointZero;
        
        [gameLayer addChild:_background];
    }
    */
    
    _slotTexture = [SKTexture textureWithImageNamed:@"slot4"];
    
    _freeCellSlots = [[FCGameState shared] freeCellSlots];
    _gameSlots = [[FCGameState shared] gameSlots];
    _cardsSlots = [[FCGameState shared] cardsSlots];
    
    _cards = [[FCGameState shared] cardsArray];
    
    if( _cards != nil && _cards.count > 0 )
    {
        for( FCCard *card in _cards )
        {
            [gameLayer addChild:card];
        }
        
        for( FCSlot *slot in _freeCellSlots )
        {
            [gameLayer addChild:slot];
        }
        
        for( FCSlot *slot in _gameSlots )
        {
            [gameLayer addChild:slot];
        }
        
        for( FCSlot *slot in _cardsSlots )
        {
            [gameLayer addChild:slot];
        }
    }
    else
    {
        CGFloat margin = -35.F;
        CGFloat y = _screenSize.height - _yDelta;
        CGFloat screenWidth = _screenSize.width;
        
        for( NSInteger i = 1; i < 5; i++ )
        {
            FCSlot *slot = [FCSlot spriteNodeWithTexture:_slotTexture];
            CGFloat x = margin + (screenWidth/2.F - 2*margin) * i/5.F;
            
            [slot setScale:_mainScale];
            slot.position = CGPointMake(x, y);
            slot.slotType = FCSlotTypeFreeCell;
            slot.name = [NSString stringWithFormat:@"freeCellSlot_%@", @(i)];
            
            [slot setupPhysics];
            
            [_freeCellSlots addObject:slot];
            [gameLayer addChild:slot];
        }
        
        for( NSInteger i = 1; i < 5; i++ )
        {
            FCSlot *slot = [FCSlot spriteNodeWithTexture:_slotTexture];
            CGFloat x = screenWidth/2.F + (margin + (screenWidth/2.F - 2*margin) * i/5.F);
            
            [slot setScale:_mainScale];
            slot.position = CGPointMake(x, y);
            slot.slotType = FCSlotTypeSuitStack;
            slot.name = [NSString stringWithFormat:@"stackSlot_%@", @(i)];;
            
            [slot setupPhysics];
            
            [_cardsSlots addObject:slot];
            [gameLayer addChild:slot];
        }
        
        [self prepareCards];
    }
    
    for( FCCard *card in _cards ) card.moveDelegate = self;
}


- (void) prepareCards
{
    NSString *str = [[FCBoardHelper new] newBoardForSeed:FCGameState.shared.gameNumber];
    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    NSArray *array = [str componentsSeparatedByString:@" "];
    static CGFloat zPositionCount = 0.F;
    
    NSInteger initY = _screenSize.height - _yDeltaCards, cardIndex = 0;
    CGFloat margin = -35.F;
    
    for( NSInteger column = 0; column < 8; column++ )
    {
        NSInteger maxI = 7;
        if( column > 3 ) maxI = 6;
        
        NSInteger cardSep = [[FCGameState shared] separationForColumn:column];
        
        CGFloat x = margin + (_screenSize.width - 2*margin) * ((float)column+1.F) / 9.F;
        
        FCCard *prevCard = nil;
        
        FCSlot *gameSlot = [FCSlot spriteNodeWithTexture:_slotTexture];
        [gameSlot setScale:_mainScale];
        gameSlot.position = CGPointMake(x, initY);
        gameSlot.slotType = FCSlotTypeGame;
        gameSlot.name = [NSString stringWithFormat:@"gameSlot_%@", @(column)];
        gameSlot.column = column;
        
        [gameSlot setupPhysics];
        
        [_gameSlots addObject:gameSlot];
        [gameLayer addChild:gameSlot];
        
        for( int file = 0; file < maxI; file++ )
        {
            zPositionCount = 0;
            CGFloat y = initY - (cardSep * file);
            
            FCCard *card = [FCCard cardWithType:array[cardIndex] parentNode:gameLayer];
            
            card.position = CGPointMake(x, y);
            card.zPosition = (zPositionCount = zPositionCount + 1.F);
            card.color = [SKColor colorWithRed:.1F green:.5F blue:.8F alpha:1.F];
            [card setScale:_mainScale];
            
            card.column = column;
            card.parentSlot = gameSlot;
            card.parentCard = prevCard;
            prevCard.childCard = card;
            
            // if( file == maxI-1 )
            {
                [card setupPhysics];
            }
            
            if( file == 0 )
            {
                gameSlot.lastCard = card;
                card.parentSlot = gameSlot;
            }
            
            prevCard = card;
            
            [_cards addObject:card];
            
            cardIndex ++;
            gameSlot = nil;
        }
    }
}


#pragma mark - Runtime getters

- (FCCard *) getLastTouchedChildFromCard:(FCCard *) card touchLocation:(CGPoint)touchLocation
{
    FCCard *lastTouchedChild = card, *nextChild;
    
    while( (nextChild = lastTouchedChild.childCard) != nil )
    {
        if( CGRectContainsPoint(nextChild.frame, touchLocation) )
        {
            lastTouchedChild = nextChild;
        }
        else
        {
            break;
        }
    }
    return lastTouchedChild;
}


- (NSInteger) numberOfMovableChildCards:(BOOL)touchingGameSlot
{
    NSInteger freeFreecellSlots = 0, freeGameSlots = 0;
    
    for( FCSlot *slot in _freeCellSlots )
    {
        if( slot.lastCard == nil ) freeFreecellSlots ++;
    }
    for( FCSlot *slot in _gameSlots )
    {
        if( slot.lastCard == nil ) freeGameSlots ++;
    }
    
    if( touchingGameSlot )
    {
        freeGameSlots --;
    }
    
    NSInteger ret;
    
    // ret = (freeFreecellSlots + 1) + ((freeFreecellSlots?freeFreecellSlots:1) * freeGameSlots);
    ret = (freeFreecellSlots) + ((freeFreecellSlots? freeFreecellSlots: 1) * freeGameSlots);
    
    return ret;
}


#pragma mark - Touch delegate methods

- (CGPoint) touchLocation:(NSSet *)touches
{
    CGPoint touchLocation = [touches.anyObject locationInNode:self];
    
    if( touches.count == 2 )
    {
        NSArray *allTouches = touches.allObjects;
        UITouch *touch1 = allTouches[0];
        UITouch *touch2 = allTouches[1];
        
        CGPoint p1 = [touch1 locationInNode:self];
        CGPoint p2 = [touch2 locationInNode:self];
        
        touchLocation = CGPointMake( (p1.x+p2.x)/2.F, (p1.y+p2.y)/2.F );
    }
    
    return touchLocation;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // NSLog(@"%s", __FUNCTION__);

    CGPoint location = [self touchLocation:touches];
    _touchMoveLocation = location;
    
    if( touches.count > 1 || _movingCard ) return;
    
    _longTouchTriggered = NO;
    _longTouchBeganPoint = location;
    _longTouchTime = 0.F;

    if( gameLayer.position.x == 0 )
    {
        for( FCCard *card in _cards )
        {
            if( CGRectContainsPoint(card.frame, location) && [card allChildCardsAreMovable] && card.stacked == NO )
            {
                _movingCard = [self getLastTouchedChildFromCard:card touchLocation:location];
                
                if( _movingCard.allChilds.count > [self numberOfMovableChildCards:NO] )
                {
                    _movingCard = nil;
                }
                else
                {
                    _previousZPosition = _movingCard.zPosition;
                    _movingCard.zPosition = kZPositionMove;
                }
                break;
            }
        }
    }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    _longTouchBeganPoint = CGPointZero;
    _longTouchTime = 0.F;
    
    CGPoint location = [self touchLocation:touches];
    
    _touchNode.zPosition = kZPositionMove;
    _touchNode.position = location;
    
    // NSLog(@"-- touches.count = %lu -- location = %@", (unsigned long)touches.count, NSStringFromCGPoint(location));
    
    CGPoint inc = CGPointMake(location.x-_touchMoveLocation.x, location.y - _touchMoveLocation.y);
    
    if( _movingCard && touches.count == 1 )
    {
        _dragging = YES;
        _movingCard.position = CGPointMake(_movingCard.position.x + inc.x, _movingCard.position.y + inc.y);
    }
    else if( touches.count == 2 )
    {
        [self moveMenuWithDeltaPoint:inc];
    }
    
    _touchMoveLocation = location;
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{    
    if( !_longTouchTriggered )
    {
        UITouch *touch = [touches anyObject];
        
        if( touch.tapCount == 2 )
        {
            [self handleDoubleTap];
        }
        else if( _dragging )
        {
            [self handleTap];
        }
        else
        {
            [self menuOpen:NO];
        }
    }
    _longTouchTime = 0.F;
    _longTouchBeganPoint = CGPointZero;
    _contactNode = _movingCard = nil;
    _dragging = NO;
    
    _previousZPosition = 0.F;
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    // NSLog(@"%s", __FUNCTION__);
    _movingCard = nil;
    _dragging = NO;
}

- (void) handleTap
{
    if( _movingCard && _contactNode && [(FCSpriteNode *)_contactNode canBeParentOf:_movingCard] )
    {
        if( [_contactNode isKindOfClass:[FCCard class]] )
        {
            [_movingCard becomeChildOfCard:(FCCard *)_contactNode];
        }
        else
        {
            [_movingCard becomeChildOfSlot:(FCSlot *)_contactNode];
        }
        _autoStackMoving = YES;
    }
    else
    {
        [_movingCard restorePosition];
    }
}

- (void) handleDoubleTap
{
    if( _movingCard )
    {
        if( _movingCard.column == -1 )
        {
            // Go to stacked slot
            for( FCSlot *slot in _cardsSlots )
            {
                if( [slot.lastCard canBeParentOf:_movingCard] )
                {
                    [_movingCard becomeChildOfCard:slot.lastCard];
                    return;
                }
            }
            
            for( FCSlot *slot in _gameSlots )
            {
                // Go to empty game slot
                if( slot.lastCard == nil )
                {
                    [_movingCard becomeChildOfSlot:slot];
                    break;
                }
                
                // Go to some parent card in game slot
                FCCard *targetCard = slot.lastCard.lastChild? slot.lastCard.lastChild: slot.lastCard;
                if( [targetCard canBeParentOf:_movingCard] )
                {
                    [_movingCard becomeChildOfCard:targetCard];
                    break;
                }
            }
        }
        else
        {
            FCCard *targetCard = nil;
            FCSlot *targetSlot = nil;
            
            for( int i = 3; i >= 0; i-- )
            {
                FCSlot *slot = _cardsSlots[i];
                if( [slot canBeParentOf:_movingCard] )
                {
                    targetSlot = slot;
                }
                else if( [slot.lastCard canBeParentOf:_movingCard] )
                {
                    targetCard = slot.lastCard;
                }
            }
            
            if( targetCard )
            {
                [_movingCard becomeChildOfCard:targetCard];
            }
            else if( targetSlot )
            {
                [_movingCard becomeChildOfSlot:targetSlot];
            }
            else
            {
                for( int i = 0; i < _freeCellSlots.count; i++ )
                {
                    FCSlot *slot = _freeCellSlots[i];
                    if( [slot canBeParentOf:_movingCard] )
                    {
                        targetSlot = slot;
                        break;
                    }
                }
                
                if( targetSlot )
                {
                    [_movingCard becomeChildOfSlot:targetSlot];
                }
            }
            
            if( targetCard || targetSlot )
            {
                _autoStackMoving = YES;
            }
        }
    }
}

#ifdef DEBUG
- (void) handleLongTap
{
    NSLog(@"%@", _movingCard);
    CGPoint location = _longTouchBeganPoint;
    FCSpriteNode *targetNode = nil;
    
    if( gameLayer.position.x == 0 )
    {
        for( FCCard *card in _cards )
        {
            if( CGRectContainsPoint(card.frame, location) )
            {
                targetNode = [self getLastTouchedChildFromCard:card touchLocation:location];
                break;
            }
        }
        
        if( !targetNode )
        {
            NSMutableArray *slots = [NSMutableArray arrayWithArray:_freeCellSlots];
            [slots addObjectsFromArray:_cardsSlots];
            [slots addObjectsFromArray:_gameSlots];
            for( FCSlot *slot in slots )
            {
                if( CGRectContainsPoint(slot.frame, location) )
                {
                    targetNode = slot;
                    break;
                }
            }
        }
    }
    
    if( targetNode )
    {
        if( _previousZPosition == 0.F )
        {
            _previousZPosition = targetNode.zPosition;
        }
        targetNode.zPosition = _previousZPosition;
        
        location = CGPointMake(location.x, self.frame.size.height - location.y);
        NSDictionary * userInfo = @{@"location": [NSValue valueWithCGPoint:location], @"target": targetNode, @"previousZ":@(_previousZPosition)};
        [self.presentationDelegate shouldPresentModalForAction:FCModalActionCartDetail userInfo:userInfo];
    }
}
#endif

#pragma mark - Contact delegate methods

- (void) didBeginContact:(SKPhysicsContact *)contact
{
    FCSpriteNode *contactNode;
    
    if( contact.bodyA.node == _movingCard )
    {
        contactNode = (FCSpriteNode *) contact.bodyB.node;
    }
    else
    {
        contactNode = (FCSpriteNode *) contact.bodyA.node;
    }
    
    if( [contactNode isKindOfClass:[FCSlot class]] )
    {
        FCSlot *slot = (FCSlot *) contactNode;
        
        if( slot.slotType == FCSlotTypeSuitStack && slot.lastCard != nil )
        {
        }
        else
        {
            if( slot.slotType == FCSlotTypeSuitStack || _movingCard.allChilds.count <= [self numberOfMovableChildCards:YES] )
            {
                if( [slot canBeParentOf:_movingCard] )
                {
                    [_contactNodes addObjectOnce:contactNode];
                }
                
                _contactNode = contactNode;
            }
        }
    }
    else
    {
        if( [(FCCard *)contactNode isChildOfCard:_movingCard] ) return;
        
        if( [contactNode canBeParentOf:_movingCard] )
        {
            [_contactNodes addObjectOnce:contactNode];
        }
        
        _contactNode = contactNode;
    }
}

- (void) didEndContact:(SKPhysicsContact *)contact
{
    FCSpriteNode *contactNode;
    
    if( contact.bodyA.node == _movingCard )
    {
        contactNode = (FCSpriteNode *) contact.bodyB.node;
    }
    else
    {
        contactNode = (FCSpriteNode *) contact.bodyA.node;
    }
    
    if( [contactNode respondsToSelector:@selector(highlight:)]) [contactNode highlight:NO];
    [_contactNodes removeObject:contactNode];
    
    if( _contactNode == contactNode ) _contactNode = nil;
}


#pragma mark - Private methods

- (void) highlighContactNodes
{
    if( _movingCard == nil )
    {
        for( FCSpriteNode *sprite in _contactNodes )
        {
            if( [sprite respondsToSelector:@selector(highlight:)] ) [sprite highlight:NO];
        }
        
        [_contactNodes removeAllObjects];
    }
    else
    {
        FCSpriteNode *spriteToHighlight = nil;
        FCSpriteNode *spriteToNormal = nil;
        
        if( _contactNodes.count == 1 )
        {
            spriteToHighlight = _contactNodes[0];
        }
        else if( _contactNodes.count == 2 )
        {
            FCSpriteNode *n1, *n2;
            
            n1 = _contactNodes[0];
            n2 = _contactNodes[1];
            
            CGFloat distance0 = [n1 distanceFromSprite:_movingCard];
            CGFloat distance1 = [n2 distanceFromSprite:_movingCard];
            
            if( distance0 < distance1 )
            {
                spriteToHighlight = n1;
                spriteToNormal = n2;
            }
            else if( distance0 > distance1 )
            {
                spriteToHighlight = n2;
                spriteToNormal = n1;
            }
        }
        else if( _contactNodes.count != 0 )
        {
            NSLog(@"WARNING: %s -> _contactNodes.count = %ld", __FUNCTION__, (unsigned long)_contactNodes.count);
            [_contactNodes removeAllObjects];
            return;
        }
        
        if( spriteToHighlight )
        {
            if( [spriteToHighlight respondsToSelector:@selector(highlight:)] && [spriteToHighlight canBeParentOf:_movingCard] )
            {
                [spriteToHighlight highlight:YES];
                _contactNode = spriteToHighlight;
            }
        }
        
        if( spriteToNormal )
        {
            if( [spriteToNormal respondsToSelector:@selector(highlight:)] )
            {
                [spriteToNormal highlight:NO];
            }
        }
    }
}

- (BOOL) checkGameSolved
{
    BOOL bRet = YES;
    
    //*
    for( FCCard *card in _cards )
    {
        if( card.stacked == NO )
        {
            bRet = NO;
            break;
        }
    }
    // */
    /*
    for( FCSlot *slot in _cardsSlots )
    {
        if( slot.lastCard.number != FCCardNumberTypeKing )
        {
            bRet = NO;
            break;
        }
    }
    // */
    /*
    for( FCSlot *slot in _freeCellSlots )
    {
        if( slot.lastCard == nil )
        {
            bRet = NO;
            break;
        }
    }
    // */
    // NSLog(@"checkGameSolved returning %@", bRet?@"YES":@"NO");
    return bRet;
}


#pragma mark - Main Menu delegate methods

- (void) mainMenu:(FCMenuScene *)menu didSelectButtonWithTag:(FCMainMenuButtonTag)buttonTag
{
    BOOL closeMenu = YES;
    
    switch( buttonTag )
    {
        case FCMainMenuButtonTagUndo:
            if( [[FCGameState shared] undoAvailable] )
                [self undoMenuOption];
            else
                closeMenu = NO;
            break;
            
        case FCMainMenuButtonTagNewGame:
            [self.presentationDelegate shouldPresentModalForAction:FCModalActionNewGame userInfo:nil];
            break;
            
        case FCMainMenuButtonTagResetGame:
            [self.presentationDelegate shouldPresentModalForAction:FCModalActionReset userInfo:nil];
            // [self resetMenuOption];
            break;
            
        case FCMainMenuButtonTagCredits:
            break;
            
        default:
            ;
            break;
    };
    if( closeMenu ) [self moveMenuTouchEnded:CGPointZero];
}

- (void) checkAutoStackCards
{
    NSLog(@" ------> %s called", __FUNCTION__);
    if( FCGameState.shared.autoStack == NO ) return;
    if( _autoMovingCard == YES ) return;
    
    NSLog(@" ------> %s continuing", __FUNCTION__);
    
    _autoStackMoving = NO;
    
    for( FCCard *card in _cards )
    {
        if( !card.stacked && card.number == FCCardNumberTypeAce && card.childCard == nil )
        {
            NSLog(@"+++++++> %s moving card with name %@", __FUNCTION__, card.name);
            FCSlot *slot = [self firstFreeStackSlot];
            card.zPosition = kZPositionMove;
            [card becomeChildOfSlot:slot];
            
            _autoStackMoving = YES;
            
            return;
        }
        else if( !card.stacked && card.childCard == nil )
        {
            FCCard *posibleParent = [[FCGameState shared] cardWithSuit:card.suit andNumber:card.number-1];
            
            if( posibleParent.stacked && (card.number == 2 || [[FCGameState shared] possibleChildsAlreadyStackedForCard:card]) )
            {
                NSLog(@"+++++++> %s moving card with name %@", __FUNCTION__, card.name);
                
                card.zPosition = kZPositionMove;
                [card becomeChildOfCard:posibleParent];
                
                _autoStackMoving = YES;
                return;
            }
        }
    }
}

- (FCSlot *) firstFreeStackSlot
{
    for( FCSlot *slot in _cardsSlots )
    {
        if( slot.lastCard == nil )
        {
            return slot;
        }
    }
    return nil;
}

#pragma mark - FCCardMoveEndedDelegate methods

- (void) card:(FCCard *)card willMoveToPosition:(CGPoint)position
{
    _autoMovingCard = YES;
}

- (void) card:(FCCard *)card didMoveToPosition:(CGPoint)position
{
    _autoMovingCard = NO;
    
    if( [self checkGameSolved] )
    {
        [self.presentationDelegate shouldPresentModalForAction:FCModalActionGameSolved userInfo:nil];
        self.paused = YES;
    }
    
    if( _autoStackMoving )
    {
        [self checkAutoStackCards];
    }
}


#pragma mark - update

- (void) deltaUpdate:(CFTimeInterval) currentTime timeDelta:(CFTimeInterval) timeDelta
{
    [self highlighContactNodes];
    
    static BOOL flag = YES;
    
    //*
    if( ![FCGameState shared].undoAvailable )
    {
        FCMenuButton *button = [_menuScene buttonWithTag:FCMainMenuButtonTagUndo];
        SKColor *color = [SKColor colorWithRed:.5F green:.5F blue:.5F alpha:1.F];
        button.color = color;
        button.colorBlendFactor = 1.F;
        flag = YES;
    }
    else if( flag )
    {
        flag = NO;
        FCMenuButton *button = [_menuScene buttonWithTag:FCMainMenuButtonTagUndo];
        button.colorBlendFactor = 0.F;
    }
    // */
#ifdef DEBUG
    _longTouchTime += timeDelta;
    if( _longTouchTime > kLongPressTime && !_longTouchTriggered && _longTouchBeganPoint.x != 0.F )
    {
        [self handleLongTap];
        _longTouchTriggered = YES;
    }
#endif
   
    /*
    if( [self checkGameSolved] )
    {
        // TODO. GAME SOLVED!!
        [self.presentationDelegate shouldPresentModalForAction:FCModalActionGameSolved userInfo:nil];
        self.paused = YES;
    }
    */
}

- (void) update:(CFTimeInterval)currentTime
{
    static CFTimeInterval timeDelta = 0.F, timeFromZero = 0.F;
    
    if( timeDelta == 0.F )
    {
        timeDelta = currentTime;
    }
    
    timeFromZero += (currentTime - timeDelta);
    
    [self deltaUpdate:timeFromZero timeDelta:(currentTime - timeDelta)];
    timeDelta = currentTime;
}

@end

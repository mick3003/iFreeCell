//
//  FCMyScene.m
//  iFreeCell
//
//  Created by Miguel Estévez on 03/08/13.
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
    BOOL _autoStackedMoved;
    
    CGFloat _previousZPosition;
}

@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;

@end


@implementation FCGameScene

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        gameLayer = [SKNode node];
        gameLayer.position = CGPointZero;
        gameLayer.zPosition = kZPositionGameLayer;
        
        _contactNodes = [NSMutableArray new];
        
        [self addChild:gameLayer];
        
        _screenSize = size;
        _mainScale = .65F;
        
        self.backgroundColor = [SKColor colorWithRed:.14 green:.22 blue:.3 alpha:1.0];
        
        if( !_freeCellSlots )
        {
            _freeCellSlots = [NSMutableArray arrayWithCapacity:4];
        }
        
        if( !_cardsSlots )
        {
            _cardsSlots = [NSMutableArray arrayWithCapacity:4];
        }
        
        if( !_gameSlots )
        {
            _gameSlots = [NSMutableArray arrayWithCapacity:8];
        }
        
        self.physicsWorld.gravity = CGVectorMake(0.F, 0.F);
        self.physicsWorld.contactDelegate = self;
        
        _menuScene = [[FCMenuScene alloc] init];
        _menuScene.delegate = self;
        
        [self addChild:_menuScene];
        
//        UILongPressGestureRecognizer *gr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongTap:)];
//        gr.minimumPressDuration = 1.5F;
//        [[(UIViewController *)self.presentationDelegate view] addGestureRecognizer:gr];
        
        [self prepareContent];
    }
    return self;
}


#pragma mark - Prepare content

- (void) prepareContent
{
    [_freeCellSlots removeAllObjects];
    [_cardsSlots removeAllObjects];
    [_gameSlots removeAllObjects];
    
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"main_bgnd4.png"];
    background.anchorPoint = CGPointZero;
    background.position = CGPointZero;
    
    [gameLayer addChild:background];
    
    _slotTexture = [SKTexture textureWithImageNamed:@"slot2"];
    
    _cards = [[FCGameState shared] cardsArray];
    
    if( _cards != nil && _cards.count > 0 )
    {
        for( FCCard *card in _cards )
        {
            [gameLayer addChild:card];
        }
        
        _freeCellSlots = [[FCGameState shared] freeCellSlots];
        for( FCSlot *slot in _freeCellSlots )
        {
            [gameLayer addChild:slot];
        }
        
        _gameSlots = [[FCGameState shared] gameSlots];
        for( FCSlot *slot in _gameSlots )
        {
            [gameLayer addChild:slot];
        }
        
        _cardsSlots = [[FCGameState shared] cardsSlots];
        for( FCSlot *slot in _cardsSlots )
        {
            [gameLayer addChild:slot];
        }
    }
    else
    {
        CGFloat margin = -35.F;
        CGFloat y = _screenSize.height - 100.F;
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
}


- (void) prepareCards
{
    if( !_cards )
    {
        _cards = [NSMutableArray arrayWithCapacity:52];
    }
    
    NSString *str = [[FCBoardHelper new] newBoardForSeed:4];
    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    NSArray *array = [str componentsSeparatedByString:@" "];
    static CGFloat zPositionCount = 0.F;
    
    NSInteger initY = _screenSize.height - 280.F, cardIndex = 0;
    CGFloat margin = -35.F;
    
    for( NSInteger column = 0; column < 8; column++ )
    {
        NSInteger maxI = 7;
        if( column > 3 ) maxI = 6;
        
        NSInteger cardSep = [[FCGameState shared] separationForColumn:column];
        
        CGFloat x = margin + (_screenSize.width - 2*margin) * ((float)column+1.F) / 9.F;
        
        FCCard *prevCard = nil;
        
        //*
        FCSlot *gameSlot = [FCSlot spriteNodeWithTexture:_slotTexture];
        [gameSlot setScale:_mainScale];
        gameSlot.position = CGPointMake(x, initY);
        gameSlot.slotType = FCSlotTypeGame;
        gameSlot.name = [NSString stringWithFormat:@"gameSlot_%@", @(column)];
        gameSlot.column = column;
        
        [gameSlot setupPhysics];
        
        [_gameSlots addObject:gameSlot];
        [gameLayer addChild:gameSlot];
        //*/
        
        for( int file = 0; file < maxI; file++ )
        {
            CGFloat y = initY - (cardSep * file);
            
            FCCard *card = [FCCard cardWithType:array[cardIndex] parentNode:gameLayer];
            
            card.moveDelegate = self;
            card.position = CGPointMake(x, y);
            card.zPosition = (zPositionCount = zPositionCount + 1.F);
            card.color = [SKColor colorWithRed:.1F green:.5F blue:.8F alpha:1.F];
            [card setScale:_mainScale];
            
            card.column = column;
            card.parentSlot = gameSlot;
            card.parentCard = prevCard;
            prevCard.childCard = card;
            
            if(file == maxI-1)
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
    
    [[FCGameState shared] setCardsArray:_cards];
    [[FCGameState shared] setFreeCellSlots:_freeCellSlots];
    [[FCGameState shared] setCardsSlots:_cardsSlots];
    [[FCGameState shared] setGameSlots:_gameSlots];
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


- (NSInteger) numberOfMovableChildCards
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
    
    return (freeFreecellSlots + 1) + (freeFreecellSlots * freeGameSlots);
}


#pragma mark - Touch delegate methods

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if( touches.count > 2 || _movingCard ) return;
    
    UITouch *touch = [touches anyObject];
    
    // NSLog(@"%s :: tapCount = %@", __FUNCTION__, @(touch.tapCount));
    // NSLog(@"%@", NSStringFromCGPoint(gameLayer.position));
    
    CGPoint location = [touch locationInNode:self];
    _touchMoveLocation = location;

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
                
                if( _movingCard.allChilds.count >= self.numberOfMovableChildCards )
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
    
    // OJO si algo falla mirar a ver si es por haber comentado esta línea
    // if( _movingCard.allChilds.count >= self.numberOfMovableChildCards ) _movingCard = nil;
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    _longTouchBeganPoint = CGPointZero;
    _longTouchTime = 0.F;
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    CGPoint inc = CGPointMake(location.x-_touchMoveLocation.x, location.y - _touchMoveLocation.y);
    
    if( _movingCard )
    {
        _dragging = YES;
        _movingCard.position = CGPointMake(_movingCard.position.x + inc.x, _movingCard.position.y + inc.y);
    }
    else
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

        [self moveMenuTouchEnded:[touch locationInNode:self]];

        if( touch.tapCount == 2 )
        {
            [self handleDoubleTap];
        }
        else if( _dragging )
        {
            [self handleTap];
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
        // [self checkAutoStackCards];
        _autoStackedMoved = YES;
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
                if( [slot.lastCard.lastChild canBeParentOf:_movingCard] )
                {
                    [_movingCard becomeChildOfCard:slot.lastCard.lastChild];
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
                _autoStackedMoved = YES;
            }
        }
    }
}

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
                // [(FCCard *)targetNode restorePosition];
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
    
    // NSLog(@"%s -- %@", __FUNCTION__, targetNode);
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
    
    // NSLog(@"%s :: %@", __FUNCTION__, contactNode.name);
    
    if( [contactNode isKindOfClass:[FCSlot class]] )
    {
        FCSlot *slot = (FCSlot *) contactNode;
        
        if( slot.slotType == FCSlotTypeSuitStack && slot.lastCard != nil )
        {
        }
        else
        {
            if( [contactNode canBeParentOf:_movingCard] )
            {
                [_contactNodes addObjectOnce:contactNode];
            }
            
            _contactNode = contactNode;
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
    // NSLog(@"%s", __FUNCTION__);
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
    
    // NSLog(@"_contactNodes.count = %lu", (unsigned long)_contactNodes.count);
}


#pragma mark - Private methods

- (void) highlighContactNodes
{
    // NSLog(@"%s -> _contactNodes.count = %ld", __FUNCTION__, (unsigned long)_contactNodes.count);
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
    
    for( FCSlot *slot in _cardsSlots )
    {
        if( slot.lastCard.number != FCCardNumberTypeKing )
        {
            bRet = NO;
            break;
        }
    }
    
    return bRet;
}


#pragma mark - update

- (void) deltaUpdate:(CFTimeInterval) currentTime timeDelta:(CFTimeInterval) timeDelta
{
    // NSLog(@"- deltaUpdate:%.3f timeDelta:%.3f", currentTime, timeDelta);
    
    [self highlighContactNodes];
    
    static BOOL flag = YES;
    
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
    
#ifdef DEBUG
    _longTouchTime += timeDelta;
    if( _longTouchTime > kLongPressTime && !_longTouchTriggered && _longTouchBeganPoint.x != 0.F )
    {
        [self handleLongTap];
        _longTouchTriggered = YES;
    }
#endif
    
    if( 0 ) //[self checkGameSolved] )
    {
        // TODO. GAME SOLVED!!
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"iFreeCell" message:@"GAME SOLVED!" delegate:nil
                                                  cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
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


#pragma mark - Main Menu delegate methods

- (void) reset
{
    [[FCGameState shared] resetState];
    
    for( SKSpriteNode *node in _cardsSlots )
    {
        [node removeFromParent];
    }
    
    for( SKSpriteNode *node in _cards )
    {
        [node removeFromParent];
    }
    
    for( SKSpriteNode *node in _freeCellSlots )
    {
        [node removeFromParent];
    }
    
    for( SKSpriteNode *node in _gameSlots )
    {
        [node removeFromParent];
    }
    
    [_freeCellSlots removeAllObjects];
    [_cardsSlots removeAllObjects];
    [_gameSlots removeAllObjects];
    [_cards removeAllObjects];
}

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
            [self reset];
            [self prepareContent];
            break;
            
        case FCMainMenuButtonTagCredits:
            break;
            
        default:
            ;
            break;
    };
    if( closeMenu ) [self moveMenuTouchEnded:CGPointZero];
}

/*
 una carta que se queda sin hijos, debe subir
 al stack si su carta inmediatamente inferior esta
 stacked
 y
 ambas cartas de color contrario y
 número inmediatamente inferior están ya en el
 stacked
 o
 es un as o un dos.
 */

- (void) checkAutoStackCards
{
    _autoStackedMoved = NO;
    
    for( FCCard *card in _cards )
    {
        if( !card.stacked && card.number == FCCardNumberTypeAce && card.childCard == nil )
        {
            FCSlot *slot = [self firstFreeStackSlot];
            card.zPosition = kZPositionMove;
            [card becomeChildOfSlot:slot];
            
            _autoStackedMoved = YES;
            break;
        }
        else if( !card.stacked && card.childCard == nil )
        {
            FCCard *posibleParent = [[FCGameState shared] cardWithSuit:card.suit andNumber:card.number-1];
            
            if( posibleParent.stacked && (card.number == 2 || [[FCGameState shared] possibleChildsAlreadyStackedForCard:card]) )
            {
                card.zPosition = kZPositionMove;
                [card becomeChildOfCard:posibleParent];
                
                _autoStackedMoved = YES;
                break;
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

- (void) card:(FCCard *)card didMoveToPosition:(CGPoint)position
{
    if( _autoStackedMoved )
    {
        [self checkAutoStackCards];
    }
}

@end

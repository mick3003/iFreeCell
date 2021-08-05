//
//  FCCard.m
//  iFreeCell
//
//  Created by Miguel Estévez on 14/08/16.
//  Copyright (c) 2013 Miguel Estévez. All rights reserved.
//

#import "FCCard.h"
#import "FCSlot.h"


@implementation FCCard

#pragma mark - Constructors & initialization

+ (BOOL) supportsSecureCoding
{
    return YES;
}

+ (id) cardWithType:(NSString *)type parentNode:(SKNode *)parent
{
    return [[self alloc] initWithType:type parentNode:parent];
}

- (id) initWithType:(NSString *)type parentNode:(SKNode *)parent
{
    // NSLog(@"%s:%@", __FUNCTION__, type);
    
    type = [type lowercaseString];
    
    self = [super initWithImageNamed:type];
    
    if( self )
    {
        self.name = type;
        _type = type;
        _number = [self numberFromTypeString:type];
        _suit = [self suitFromTypeString:type];
        _stacked = NO;
        
        if( parent ) [parent addChild:self];
    }
    
    return self;
}


#pragma mark - Runtime properties & checks

- (FCCard *) firstParent
{
    FCCard *firstParent = self.parentCard;
    
    while (firstParent)
    {
        if( firstParent.parentCard == nil ) break;
        firstParent = firstParent.parentCard;
    }
    
    return firstParent;
}

- (FCCard *) lastChild
{
    FCCard *lastChild = self.childCard;
    
    while (lastChild)
    {
        if( lastChild.childCard == nil ) break;
        lastChild = lastChild.childCard;
    }
    
    return lastChild;
}

- (NSArray *) allChilds
{
    NSMutableArray *childs = [NSMutableArray new];
    FCCard *child = self.childCard;
    
    while( child )
    {
        [childs addObject:child];
        child = child.childCard;
    }
    return childs;
}

- (FCSlot *) firstParentSlot
{
    FCCard *card = self;
    
    while (card.parentCard)
    {
        card = card.parentCard;
    }
    
    return card.parentSlot;
}

- (BOOL) isChildOfCard:(const FCCard *)card
{
    BOOL bRet = NO;
    
    FCCard *parent = card.parentCard;
    
    while( parent != nil )
    {
        if( parent == card )
        {
            bRet = YES;
            break;
        }
        parent = parent.parentCard;
    }
    
    return bRet;
}

- (BOOL) canBeParentOf:(FCSpriteNode *)child
{
    BOOL bRet = NO;
    
    FCCard *childCard = (FCCard *) child;
    
    if( self.inFreeCell == NO && self.childCard == nil )
    {
        if( self.stacked )
        {
            if( _number +1 == childCard.number && _suit == childCard.suit )
            {
                bRet = YES;
            }
        }
        else if( _number-1 == childCard.number && _isRed == !childCard.isRed )
        {
            bRet = YES;
        }
    }
    
    return bRet;
}

- (BOOL) childCardIsMovable
{
    BOOL bRet = ( _number+1 == _parentCard.number && _isRed == !_parentCard.isRed );
    // NSLog(@"childCardIsMovable returning %@ for card with name %@", bRet?@"YES":@"NO", self.name);
    return bRet;
}

- (BOOL) allChildCardsAreMovable
{
    BOOL bRet = YES;
    
    FCCard *nextChild = self.childCard;
    
    while( nextChild != nil )
    {
        if( [nextChild childCardIsMovable] )
        {
            nextChild = nextChild.childCard;
        }
        else
        {
            bRet = NO;
            break;
        }
    }
    
    // NSLog(@"allChildCardsAreMovable returning %@ for card with name %@", bRet? @"YES":@"NO", self.name);
    return bRet;
}


#pragma mark - Movement and positions

- (void) setColumn:(NSInteger)column
{
    _column = column;
    self.childCard.column = column;
}

- (void) setPosition:(CGPoint)position
{
    [super setPosition:position];
    
    if( self.lastPosition.x == 0.F )
    {
        self.lastPosition = position;
    }
    
    [self.childCard setPosition:[self getPositionFromParentPosition:position]];
}

- (void) setZPosition:(CGFloat)zPosition
{
    [super setZPosition:zPosition];
    [self.childCard setZPosition:zPosition+1.F];
}

- (void) moveToPosition:(CGPoint) point
{
    // NSLog(@"Moving %@ TO %@", self, [[FCPoint pointWithCGPoint:point] description]);
    // SKAction *move = [SKAction moveTo:point duration:.15];
    [self.moveDelegate card:self willMoveToPosition:point];
    SKAction *move = [SKAction moveTo:point duration:0.8];
    
    __weak typeof(self) weakSelf = self;
    
    [self runAction:move completion:^
     {
         if( weakSelf.parentSlot )
         {
             if( weakSelf.number == FCCardNumberTypeKing )
             {
                 weakSelf.zPosition = kZPositionGameLayer + 1;
                 weakSelf.parentSlot.lastCard = self;
             }
             else
             {
                 if( weakSelf == self.parentSlot.lastCard )
                 {
                     weakSelf.zPosition = kZPositionGameLayer + 1;
                     
                 }
                 else
                 {
                     weakSelf.zPosition = self.parentSlot.lastCard.zPosition + 1.F;
                     weakSelf.parentSlot.lastCard = self;
                 }
             }
         }
         else
         {
             weakSelf.zPosition = weakSelf.parentCard.zPosition + 1.F;
         }
         [self.moveDelegate card:self didMoveToPosition:self.position];
     }];
    
    self.lastPosition = point;
    if( self.childCard )
        [self.childCard moveToPosition:[self getPositionFromParentPosition:point]];
}
/*
 - (void) moveToPosition:(CGPoint) point
 {
     // NSLog(@"Moving %@ TO %@", self, [[FCPoint pointWithCGPoint:point] description]);
     // SKAction *move = [SKAction moveTo:point duration:.15];
     SKAction *move = [SKAction moveTo:point duration:1.2];
     
     __weak typeof(self) weakSelf = self;
     
     [self runAction:move completion:^
      {
          if( weakSelf.parentSlot )
          {
              if( weakSelf.number == FCCardNumberTypeKing )
              {
                  weakSelf.zPosition = kZPositionGameLayer + 1;
                  weakSelf.parentSlot.lastCard = self;
              }
              else
              {
                  if( weakSelf == self.parentSlot.lastCard )
                  {
                      weakSelf.zPosition = kZPositionGameLayer + 1;
                      
                  }
                  else
                  {
                      weakSelf.zPosition = self.parentSlot.lastCard.zPosition + 1.F;
                      weakSelf.parentSlot.lastCard = self;
                  }
              }
          }
          else
          {
              weakSelf.zPosition = weakSelf.parentCard.zPosition + 1.F;
          }
          [self.moveDelegate card:self didMoveToPosition:self.position];
      }];
     
     self.lastPosition = point;
     if( self.childCard )
         [self.childCard moveToPosition:[self getPositionFromParentPosition:point]];
 }
 */

- (void) restorePosition
{
    [self.parentCard highlight:NO];
    [self moveToPosition:self.lastPosition];
    // OJO OJO
    // [self.childCard moveToPosition:[self getPositionFromParentPosition:self.lastPosition]];
}

- (void) becomeChildOfCard:(FCCard *) pCard
{
    [self becomeChildOfCard:pCard fromUndo:NO];
}

- (void) becomeChildOfCard:(FCCard *)pCard fromUndo:(BOOL)fromUndo
{
    if( !fromUndo)
    {
        [[FCGameState shared] addMoveWithTargetCard:self andPreviousParent:self.parentCard? self.parentCard: self.parentSlot];
    }
    
    [self.parentCard setupPhysics];
    
    self.parentCard.childCard = nil;
    
    pCard.childCard = self;
    self.parentSlot.lastCard = nil;
    self.parentSlot = nil;
    self.inFreeCell = NO;
    
    self.parentCard = pCard;
    self.parentCard.colorBlendFactor = 0.F;
    self.column = pCard.column;
    
    //*
    self.stacked = self.parentCard.stacked;
    
    if( pCard.stacked )
    {
        [pCard unsetPhysics];
    }
    // */
        
    [self moveToPosition:[self getPositionFromParentPosition:pCard.position]];
}

- (void) becomeChildOfSlot:(FCSlot *)slot
{
    [self becomeChildOfSlot:slot fromUndo:NO];
}

- (void) becomeChildOfSlot:(FCSlot *)slot fromUndo:(BOOL)fromUndo
{
    if( !fromUndo)
    {
        [[FCGameState shared] addMoveWithTargetCard:self andPreviousParent:self.parentCard? self.parentCard: self.parentSlot];
    }
    
    [self.parentCard setupPhysics];
    
    self.parentCard.childCard = nil;
    self.parentCard = nil;
    
    self.parentSlot.lastCard = nil;
    self.parentSlot = slot;
    
    if( slot.slotType == FCSlotTypeSuitStack )
    {
        self.inFreeCell = NO;
        self.stacked = YES;
        self.column = -1;
        self.childCard = nil;
    }
    else if( slot.slotType == FCSlotTypeFreeCell )
    {
        self.inFreeCell = YES;
        self.stacked = NO;
        self.column = -1;
        self.childCard = nil;
    }
    else if( slot.slotType == FCSlotTypeGame )
    {
        self.inFreeCell = NO;
        self.stacked = NO;
        self.column = slot.column;
    }
    
    [self moveToPosition:slot.position];
}
    
- (CGPoint) getPositionFromParentPosition:(CGPoint) parentPosition
{
    CGPoint retPoint = parentPosition;
    
    if( self.parentCard.stacked )
        retPoint = self.parentCard.firstParentSlot.position;
    else
        retPoint.y = retPoint.y - [[FCGameState shared] separationForColumn:self.column];
    
    return retPoint;
}


#pragma mark - Physics

- (void) setupPhysics
{
    if( self.physicsBody != nil )
    {
        self.physicsBody.dynamic = YES;
    }
    else
    {
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
        self.physicsBody.categoryBitMask = cardCategory;
        self.physicsBody.collisionBitMask = 0;
        self.physicsBody.contactTestBitMask = cardCategory | slotCategory;
        self.physicsBody.usesPreciseCollisionDetection = YES;
        self.physicsBody.affectedByGravity = YES;
        self.physicsBody.dynamic = YES;
    }
}

- (void) unsetPhysics
{
    // self.physicsBody.dynamic = NO;
}

- (BOOL) physicsEnabled
{
    return self.physicsBody.dynamic;
}

- (void) unsetChildsPhysics
{
    /*
    FCCard *child = self.childCard;
    
    while( child )
    {
        [child unsetPhysics];
        child = child.childCard;
    }
    // */
}

- (void) setupChildsPhysics
{
    FCCard *child = self.childCard;
    
    while( child )
    {
        [child setupPhysics];
        child = child.childCard;
    }
}


#pragma mark - Description

- (FCCardSuit) suitFromTypeString:(NSString *)type
{
    FCCardSuit ret = FCCardSuitInvalid;
    
    if( [type hasSuffix:@"s"] )
    {
        ret = FCCardSuitSpade;
        _isRed = NO;
    }
    else if( [type hasSuffix:@"h"] )
    {
        ret = FCCardSuitHeart;
        _isRed = YES;
    }
    else if( [type hasSuffix:@"d"] )
    {
        ret = FCCardSuitDiamond;
        _isRed = YES;
    }
    else if( [type hasSuffix:@"c"] )
    {
        ret = FCCardSuitClub;
        _isRed = NO;
    }
    
    return ret;
}

- (FCCardNumber) numberFromTypeString:(NSString *)type
{
    FCCardNumber ret = (FCCardNumber) [type intValue];
    
    if( ret == FCCardNumberInvalid )
    {
        if( [type hasPrefix:@"a"] )
        {
            ret = FCCardNumberTypeAce;
        }
        else if( [type hasPrefix:@"j"] )
        {
            ret = FCCardNumberTypeJack;
        }
        else if( [type hasPrefix:@"q"] )
        {
            ret = FCCardNumberTypeQueen;
        }
        else if( [type hasPrefix:@"k"] )
        {
            ret = FCCardNumberTypeKing;
        }
    }
    
    return  ret;
}

- (NSString *) numberString
{
    NSString *ret = @"";
    
    switch( _number )
    {
        case FCCardNumberTypeJack:
            ret = @"jack";
            break;
        case FCCardNumberTypeQueen:
            ret = @"queen";
            break;
        case FCCardNumberTypeKing:
            ret = @"king";
            break;
        case FCCardNumberInvalid:
        default:
            ret = [NSString stringWithFormat:@"%ld", (long)_number];
            break;
    };
    return ret;
}


- (NSString *) suitString
{
    NSString *ret = @"";
    
    switch( _suit )
    {
        case FCCardSuitClub:
            ret = @"club";
            break;
        case FCCardSuitDiamond:
            ret = @"diamond";
            break;
        case FCCardSuitHeart:
            ret = @"heart";
            break;
        case FCCardSuitSpade:
            ret = @"spade";
            break;
        case FCCardSuitInvalid:
        default:
            ret = @"----";
            break;
    };
    return ret;
}

- (NSString *) colorString
{
    NSString *ret = @"black";
    
    if( _isRed ) ret = @"red";
    
    return ret;
}

- (NSString *) stackedString
{
    NSString *ret = @"NO";
    
    if( _stacked ) ret = @"YES";
    
    return ret;
}

- (NSString *) inFreeCellString
{
    NSString *ret = @"NO";
    
    if( _inFreeCell ) ret = @"YES";
    
    return ret;
}

- (NSString *) description
{
    return [NSString stringWithFormat:
@"<CFCard %p>:\nnumber = %@ :: suit = %@ | isRed = %@ | \
stacked = %@ | inFreeCell = %@ | position = (%f, %f) | \
zPosition = %.2f | physics = %@ | parentCardName = %@ | parentSlotName = %@ | childCardType = %@ | lastChildType = %@",
            self, [self numberString], [self suitString], [self colorString],
            [self stackedString], [self inFreeCellString], self.frame.origin.x, self.frame.origin.y,
            self.zPosition, self.physicsEnabled?@"YES":@"NO", self.parentCard.name, self.parentSlot.name, self.childCard.name, self.lastChild.name];
}


#pragma mark - NSCoding protocol

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeObject:self.type forKey:@"type"];
    [aCoder encodeObject:@(self.number) forKey:@"number"];
    [aCoder encodeObject:@(self.suit) forKey:@"suit"];
    [aCoder encodeObject:@(self.isRed) forKey:@"isRed"];
    [aCoder encodeObject:@(self.stacked) forKey:@"stacked"];
    [aCoder encodeObject:@(self.inFreeCell) forKey:@"inFreeCell"];
    [aCoder encodeObject:@(self.column) forKey:@"column"];
    [aCoder encodeObject:@(self.lastPosition.x) forKey:@"lastPosition.x"];
    [aCoder encodeObject:@(self.lastPosition.y) forKey:@"lastPosition.y"];
    [aCoder encodeObject:self.parentCard forKey:@"parentCard"];
    [aCoder encodeObject:self.childCard forKey:@"childCard"];
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    if( (self = [super initWithCoder:aDecoder]) )
    {
        _type = [aDecoder decodeObjectForKey:@"type"];
        _number = (FCCardNumber) [[aDecoder decodeObjectForKey:@"number"] integerValue];
        _suit = (FCCardSuit) [[aDecoder decodeObjectForKey:@"suit"] integerValue];
        _isRed = [[aDecoder decodeObjectForKey:@"isRed"] boolValue];
        _stacked = [[aDecoder decodeObjectForKey:@"stacked"] boolValue];
        _inFreeCell = [[aDecoder decodeObjectForKey:@"inFreeCell"] boolValue];
        _column = [[aDecoder decodeObjectForKey:@"column"] integerValue];
        CGFloat x = [[aDecoder decodeObjectForKey:@"lastPosition.x"] floatValue];
        CGFloat y = [[aDecoder decodeObjectForKey:@"lastPosition.y"] floatValue];
        _lastPosition = CGPointMake(x, y);
        _parentCard = [aDecoder decodeObjectForKey:@"parentCard"];
        _childCard = [aDecoder decodeObjectForKey:@"childCard"];
    }
    return self;
}

@end

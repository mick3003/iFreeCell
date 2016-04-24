//
//  FCCard.h
//  iFreeCell
//
//  Created by Miguel Estévez on 14/08/13.
//  Copyright (c) 2013 Miguel Estévez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

#import "FCSpriteNode.h"

@class FCSlot;
@class FCCard;

@protocol FCCardMoveEndedDelegate <NSObject>

- (void) card:(FCCard *)card didMoveToPosition:(CGPoint)position;

@end

typedef enum _cardNumber
{
    FCCardNumberInvalid = 0,
    FCCardNumberTypeAce = 1,
    FCCardNumberTypeJack = 11,
    FCCardNumberTypeQueen = 12,
    FCCardNumberTypeKing = 13
} FCCardNumber;

typedef enum _cardSuit
{
    FCCardSuitInvalid = 0,
    FCCardSuitDiamond = 1,
    FCCardSuitSpade,
    FCCardSuitHeart,
    FCCardSuitClub
} FCCardSuit;


@interface FCCard : FCSpriteNode
{
    
}

@property (nonatomic, weak) id <FCCardMoveEndedDelegate> moveDelegate;

@property (nonatomic, readonly) NSString *type;

@property (nonatomic, readonly) FCCardNumber number;
@property (nonatomic, readonly) FCCardSuit suit;
@property (nonatomic, readonly) BOOL isRed;



@property (nonatomic, assign) BOOL stacked;
@property (nonatomic, assign) BOOL inFreeCell;
@property (nonatomic, assign) NSInteger column;
@property (nonatomic, assign) CGPoint lastPosition;

@property (nonatomic, strong) FCSlot *parentSlot;

@property (nonatomic, assign) FCCard *parentCard;
@property (nonatomic, assign) FCCard *childCard;


+ (id) cardWithType:(NSString *)type parentNode:(SKNode *)parent;

- (void) unsetPhysics;
- (BOOL) physicsEnabled;
- (void) unsetChildsPhysics;
- (void) setupChildsPhysics;

- (FCCard *) firstParent;
- (FCCard *) lastChild;
- (NSArray *) allChilds;
- (FCSlot *) firstParentSlot;
- (BOOL) isChildOfCard:(const FCCard *)card;
- (CGPoint) getPositionFromParentPosition:(CGPoint) parentPosition;
- (BOOL) childCardIsMovable;
- (BOOL) allChildCardsAreMovable;
- (void) moveToPosition:(CGPoint) point;
- (void) restorePosition;
- (void) becomeChildOfCard:(FCCard *)card;
- (void) becomeChildOfCard:(FCCard *)pCard fromUndo:(BOOL)fromUndo;
- (void) becomeChildOfSlot:(FCSlot *)slot;
- (void) becomeChildOfSlot:(FCSlot *)slot fromUndo:(BOOL)fromUndo;

@end

//
//  FCMyScene.h
//  iFreeCell
//

//  Copyright (c) 2013 Miguel Estévez. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef NS_ENUM(NSInteger, FCModalAction)
{
    FCModalActionNewGame = 0,
    FCModalActionReset,
    FCModalActionCartDetail
};

@class FCSpriteNode;
@class FCCard;
@class FCSlot;

@protocol FCModalPresentationDelegate <NSObject>
@required
- (void) shouldPresentModalForAction:(FCModalAction)action userInfo:(NSDictionary *)userInfo;

@end

@interface FCGameScene : SKScene 
{
    SKNode *gameLayer;
    
    // SKSpriteNode *background;
    NSMutableArray *_freeCellSlots;
    NSMutableArray *_cardsSlots;
    NSMutableArray *_gameSlots;
    
    NSMutableArray *_cards;
    NSMutableArray *_contactNodes;
    
    CGFloat _mainScale;
    
    CGSize _screenSize;
    
    SKTexture *_slotTexture;
    
    FCCard *_card;
    FCCard *_movingCard;
    
    CGPoint _touchMoveLocation;
    
    SKSpriteNode *_contactNode;
    
    BOOL _dragging;
    
     // Menu
    
    CGFloat _menuMoveDelta;
    BOOL _menuShowing;
    BOOL _menuDragging;
}

@property (nonatomic, weak) id <FCModalPresentationDelegate> presentationDelegate;

@end

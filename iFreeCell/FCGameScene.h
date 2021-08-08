//
//  FCMyScene.h
//  iFreeCell
//

//  Copyright (c) 2013 Miguel Estévez. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

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
    NSMutableArray <FCSlot *> *_freeCellSlots;
    NSMutableArray <FCSlot *> *_cardsSlots;
    NSMutableArray <FCSlot *> *_gameSlots;
    
    NSMutableArray <FCCard *> *_cards;
    NSMutableArray <FCSpriteNode *> *_contactNodes;
    
    CGFloat _mainScale;
    
    CGSize _screenSize;
    
    SKTexture *_slotTexture;
    
    SKSpriteNode *_background;
    
    FCCard *_movingCard;
    
    CGPoint _touchMoveLocation;
    
    SKSpriteNode *_contactNode;
    
    BOOL _dragging;
}

@property (nonatomic, weak) id <FCModalPresentationDelegate> presentationDelegate;
@property (nonatomic, assign) BOOL menuShowing;

+ (instancetype) sceneWithSize:(CGSize)size gameNumber:(NSInteger)gameNumber;
- (id) initWithSize:(CGSize)size gameNumber:(NSInteger)gameNumber;

@end

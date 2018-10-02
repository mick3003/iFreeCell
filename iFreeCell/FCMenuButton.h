//
//  FCMenuButton.h
//  iFreeCell
//
//  Created by Miguel Estévez on 31/08/14.
//  Copyright (c) 2014 Miguel Estévez. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef enum _mainMenuButtonTag
{
    FCMainMenuButtonTagNewGame = 1,
    FCMainMenuButtonTagResetGame,
    FCMainMenuButtonTagCredits,
    FCMainMenuButtonTagUndo
} FCMainMenuButtonTag;


@interface FCMenuButton : SKSpriteNode
{
    
}

@property (nonatomic, assign) FCMainMenuButtonTag tag;
@property (nonatomic, strong) SKLabelNode *labelNode;

+ (id) buttonWithTexture:(SKTexture *) texture tag:(FCMainMenuButtonTag)tag andName:(NSString *) name;

@end

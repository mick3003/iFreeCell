//
//  FCMenuScene.h
//  iFreeCell
//
//  Created by Miguel Estévez on 08/08/14.
//  Copyright (c) 2014 Miguel Estévez. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "FCMenuButton.h"

@class FCMenuScene;

@protocol FCMainMenuDelegate <NSObject>
@required
- (void) mainMenu:(FCMenuScene *)menu didSelectButtonWithTag:(FCMainMenuButtonTag)buttonTag;

@end

@interface FCMenuScene : SKNode
{
    
}

@property (nonatomic, weak) id <FCMainMenuDelegate> delegate;

- (FCMenuButton *)buttonWithTag:(FCMainMenuButtonTag)tag;

@end

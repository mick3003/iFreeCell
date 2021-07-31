//
//  FCGameScene+MainMenu.h
//  iFreeCell
//
//  Created by Miguel Estévez on 01/06/14.
//  Copyright (c) 2014 Miguel Estévez. All rights reserved.
//

#import "FCGameScene.h"

@interface FCGameScene (MainMenu)
{
}

- (void) toggleMenu;
- (void) menuOpen:(BOOL)open;
- (void) moveMenuWithDeltaPoint:(CGPoint) deltaPoint;
- (void) moveMenuTouchEnded:(CGPoint) touchLocation;
- (void) resetMenuOption;
- (void) undoMenuOption;

@end

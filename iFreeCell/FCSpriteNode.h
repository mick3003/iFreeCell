//
//  FCGameSpriteNode.h
//  iFreeCell
//
//  Created by Miguel Estévez on 22/04/14.
//  Copyright (c) 2014 Miguel Estévez. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "FCPoint.h"

static const uint32_t cardCategory = 0x1 << 0;
static const uint32_t slotCategory = 0x1 << 1;


@interface FCSpriteNode : SKSpriteNode
{
    
}

@property (nonatomic) FCPoint *fcPosition;

- (void) setupPhysics;
- (void) highlight:(BOOL)value;
- (BOOL) canBeParentOf:(FCSpriteNode *)child;
- (CGFloat) distanceFromSprite:(FCSpriteNode *) node;

@end

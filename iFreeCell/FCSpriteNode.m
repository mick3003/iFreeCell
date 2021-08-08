//
//  FCGameSpriteNode.m
//  iFreeCell
//
//  Created by Miguel Estévez on 22/04/14.
//  Copyright (c) 2014 Miguel Estévez. All rights reserved.
//

#import "FCSpriteNode.h"


@interface FCSpriteNode ()
{
    BOOL _highlighted;
}

@end


@implementation FCSpriteNode

- (void) setPosition:(CGPoint)position
{
    [super setPosition:position];
    
    self.fcPosition = [FCPoint pointWithCGPoint:position];
}

- (CGFloat) distanceFromSprite:(FCSpriteNode *) node
{
   return [self.fcPosition distanceFromPoint:node.fcPosition];
}

- (void) highlight:(BOOL)value
{
    self.mustHighlight = NO;
    if( value != _highlighted )
    {
        _highlighted = value;
        CGFloat blendFactor = 0.F;
        
        if( _highlighted ) blendFactor = 1.F;
        
        SKColor *color = [SKColor colorWithRed:.1F green:.5F blue:.8F alpha:1.F];
        self.color = color;
        self.colorBlendFactor = blendFactor;
    }
}

- (void) setupPhysics
{
     NSLog(@"Stub implementation. Must be implemented by derived classes");
}

- (BOOL) canBeParentOf:(FCSpriteNode *)parent
{
    NSLog(@"Stub implementation. Must be implemented by derived classes");
    return YES;
}

@end

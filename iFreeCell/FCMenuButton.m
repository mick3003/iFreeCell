//
//  FCMenuButton.m
//  iFreeCell
//
//  Created by Miguel Estévez on 31/08/14.
//  Copyright (c) 2014 Miguel Estévez. All rights reserved.
//

#import "FCMenuButton.h"

@implementation FCMenuButton

+ (id) buttonWithTexture:(SKTexture *) texture tag:(FCMainMenuButtonTag)tag andName:(NSString *) name
{
    FCMenuButton *button = [super spriteNodeWithTexture:texture];
    
    if( button )
    {
        button.tag = tag;
        
        SKLabelNode *label = [[SKLabelNode alloc] init];
        // [label setFontName:@"AppleSDGothicNeo-Bold"];
        [label setFontName:@"HelveticaNeue-Bold"];
        [label setFontSize:16.F];
        [label setText:name];
        
        CGPoint pos = button.position;
        pos.y += 3.F;
        label.position = pos;
        label.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        label.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        //label.xScale = 0.7F;
        //label.yScale = 2.5F;
        
        [button addChild:label];
    }
    
    return button;
}

@end

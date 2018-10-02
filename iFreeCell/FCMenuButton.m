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
        
        button.labelNode = [[SKLabelNode alloc] init];
        // [label setFontName:@"AppleSDGothicNeo-Bold"];
        [button.labelNode setFontName:@"HelveticaNeue-Bold"];
        [button.labelNode setFontSize:16.F];
        [button.labelNode setName:name];
        [button.labelNode setText:name];
        
        button.name = name;
        
        CGPoint pos = button.position;
        pos.y += 3.F;
        button.labelNode.position = pos;
        button.labelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        button.labelNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        //button.labelNode.xScale = 0.7F;
        //button.labelNode.yScale = 2.5F;
        
        [button addChild:button.labelNode];
    }
    
    return button;
}

@end

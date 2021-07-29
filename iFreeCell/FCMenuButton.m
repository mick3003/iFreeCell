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
    button.tag = tag;
    button.text = name;
    button.name = name;
    button.zPosition = kZPositionMenuButtons;
    
    [button addLabel];

    return button;
}

- (void) addLabel
{
    self.labelNode = [[SKLabelNode alloc] init];
    
    NSDictionary *attributes = @{ NSForegroundColorAttributeName : [UIColor whiteColor],
                                  NSFontAttributeName: [UIFont systemFontOfSize:16.0 weight:UIFontWeightBold]
                                  
    };
    
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:self.text attributes:attributes];
    [self.labelNode setAttributedText:attrString];
    [self.labelNode setName:self.name];
    [self.labelNode setText:self.text]; // For trace purposes only

    self.labelNode.position = CGPointZero;
    self.labelNode.zPosition = kZPositionMenuLabel;
    
    [self addChild:self.labelNode];
}


@end

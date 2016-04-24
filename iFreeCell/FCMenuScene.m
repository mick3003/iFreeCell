//
//  FCMenuScene.m
//  iFreeCell
//
//  Created by Miguel Estévez on 08/08/14.
//  Copyright (c) 2014 Miguel Estévez. All rights reserved.
//

#import "FCMenuScene.h"


struct _Buttons
{
    void *text;
    FCMainMenuButtonTag buttonTag;
} _buttons[] =
{
    { @"Undo"           , FCMainMenuButtonTagUndo      },
    { @"New Game"       , FCMainMenuButtonTagNewGame   },
    { @"Reset Game"     , FCMainMenuButtonTagResetGame },
    { @"Credits"        , FCMainMenuButtonTagCredits   },
    { nil }
};

@interface FCMenuScene ()
{
    NSMutableArray *_buttonsArray;
    FCMenuButton *_touchedButton;
}
@end


@implementation FCMenuScene

-(id) init
{
    if (self = [super init])
    {
        self.position = CGPointMake(0.F, 0.F);
        self.zPosition = kZPositionMenu;
        self.name = @"menuScene";
        self.userInteractionEnabled = YES;
        
        [self prepareContent];
    }
    return self;
}

- (void) prepareContent
{
    _buttonsArray = [NSMutableArray new];
    
    SKTexture *buttonTexture = [SKTexture textureWithImageNamed:@"menuButtonBgnd"];
    
    NSInteger i = 0;
    
    CGFloat initX = 134.F;
    CGFloat initY = 650.F;
    CGFloat deltaY = 180.F;
    
    while( _buttons[i].text )
    {
        FCMenuButton *button = [FCMenuButton buttonWithTexture:buttonTexture tag:_buttons[i].buttonTag andName:(__bridge NSString *) _buttons[i].text];
        
        button.centerRect = CGRectMake(9.F/68.0, 4.F/68.F, 50.F/68.F, 49.F/68.F);
        
        CGFloat x = initX;
        CGFloat y = initY - (i * deltaY);
        button.position = CGPointMake(x, y);
        button.name = (__bridge NSString *) _buttons[i].text;
        
        [_buttonsArray addObject:button];
        [self addChild:button];

        i++;
    }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    
    _touchedButton = nil;
    
    for( FCMenuButton *button in _buttonsArray )
    {
        if( CGRectContainsPoint(button.frame, touchLocation) )
        {
            _touchedButton = button;
            break;
        }
    }
    
    if( _touchedButton != nil )
    {
        // Set highlight mode enabled...
        SKColor *color = [SKColor colorWithRed:.1F green:.5F blue:.8F alpha:1.F];
        _touchedButton.color = color;
        _touchedButton.colorBlendFactor = 1.F;
    }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    _touchedButton.colorBlendFactor = 0.F;
    
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    
    for( FCMenuButton *button in _buttonsArray )
    {
        if( CGRectContainsPoint(button.frame, touchLocation) )
        {
            _touchedButton = button;
            break;
        }
    }
    
    if( self.delegate )
    {
        [self.delegate mainMenu:self didSelectButtonWithTag:_touchedButton.tag];
    }
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    _touchedButton.colorBlendFactor = 0.F;
}

- (FCMenuButton *)buttonWithTag:(FCMainMenuButtonTag)tag
{
    FCMenuButton *retButton = nil;
    NSInteger i = 0;
    
    while( _buttons[i].text )
    {
        if( _buttons[i].buttonTag == tag )
        {
            retButton = _buttonsArray[i];
            break;
        }
    }
    return retButton;
}

@end

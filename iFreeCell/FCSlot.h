//
//  FCSlot.h
//  iFreeCell
//
//  Created by Miguel Estévez on 28/08/13.
//  Copyright (c) 2013 Miguel Estévez. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "FCSpriteNode.h"

typedef enum
{
    FCSlotTypeFreeCell = 1,
    FCSlotTypeSuitStack,
    FCSlotTypeGame
} FCSlotType;

@class FCCard;

@interface FCSlot : FCSpriteNode
{
    
}

@property (nonatomic, assign) FCSlotType slotType;

@property (nonatomic, strong) NSString *lastCardName;
@property (nonatomic, assign) FCCard *lastCard;
@property (nonatomic, assign) NSInteger column;

- (NSString *) stringFromType;

@end

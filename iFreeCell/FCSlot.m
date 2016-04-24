//
//  FCSlot.m
//  iFreeCell
//
//  Created by Miguel Estévez on 28/08/13.
//  Copyright (c) 2013 Miguel Estévez. All rights reserved.
//

#import "FCSlot.h"
#import "FCCard.h"

@implementation FCSlot

- (void) setLastCard:(FCCard *)lastCard
{
    _lastCard = lastCard;
    
    if( lastCard == nil ) _lastCardName = nil;
    else _lastCardName = lastCard.name;
}

- (BOOL) canBeParentOf:(FCSpriteNode *)child
{
    BOOL bRet = NO;
    
    switch( self.slotType )
    {
        case FCSlotTypeFreeCell:
            bRet = self.lastCard == nil && ((FCCard *)child).number != FCCardNumberTypeAce && ((FCCard *)child).childCard == nil;
            break;
        case FCSlotTypeGame:
            bRet = self.lastCard == nil && ((FCCard *)child).number != FCCardNumberTypeAce;
            break;
        case FCSlotTypeSuitStack:
            if( self.lastCard == nil )
            {
                bRet = ((FCCard *)child).number == FCCardNumberTypeAce;
            }
            else
            {
                bRet = [self.lastCard canBeParentOf:child];
            }
            break;
        default:
            ;
            break;
    };
    
    return bRet;
}


- (void) setupPhysics
{
    self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
    self.physicsBody.categoryBitMask = slotCategory;
    self.physicsBody.collisionBitMask = 0;
    self.physicsBody.contactTestBitMask = cardCategory;
    self.physicsBody.affectedByGravity = NO;
}


#pragma mark - NSCoding protocol

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeObject:@(self.slotType) forKey:@"slotType"];
    // [aCoder encodeObject:self.lastCard forKey:@"lastCard"];
    [aCoder encodeObject:self.lastCardName forKey:@"lastCardName"];
    [aCoder encodeObject:@(self.column) forKey:@"column"];
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    if( self = [super initWithCoder:aDecoder] )
    {
        self.slotType = (FCSlotType) [[aDecoder decodeObjectForKey:@"slotType"] integerValue];
        self.lastCardName = [aDecoder decodeObjectForKey:@"lastCardName"];
        self.column = [[aDecoder decodeObjectForKey:@"column"] integerValue];
        
        self.lastCard = [[FCGameState shared] cardWithName:self.lastCardName];
    }
    return self;
}


#pragma mark - Description

- (NSString *) stringFromType
{
    NSString *ret;
    switch( self.slotType )
    {
        case FCSlotTypeGame:
            ret = @"Type Game";
            break;
        case FCSlotTypeFreeCell:
            ret = @"Type FreeCell";
            break;
        case FCSlotTypeSuitStack:
            ret = @"Type Stack";
            break;
        default:
            ret = @"NO TYPE";
            break;
    };
    return ret;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"<FCSlot %p>:SlotType: %@ | lastCardName = %@ | column = %@",
            self, [self stringFromType], self.lastCardName, @(self.column)];
}

@end

//
//  FCGameState.m
//  iFreeCell
//
//  Created by Miguel Estévez on 23/08/13.
//  Copyright (c) 2013 Miguel Estévez. All rights reserved.
//

#import "FCGameState.h"
#import "FCCard.h"

#define kUserDefaultsKeySavedCardsState     @"UserDefaultsSavedCardsState"
#define kUserDefaultsKeySavedFreeCellSlots  @"UserDefaultsSavedFreeCellSlots"
#define kUserDefatulsKeySavedGameSlots      @"UserDefaultsSavedGameSlots"
#define kUserDefaultsKeySavedCardsSlots     @"UserDefaultsSavedCardsSlots"
#define kUserDefaultsKeyCardSeparations     @"UserDefaultsCardSeparations"


@implementation FCMove

- (id) initWithCoder:(NSCoder *)aDecoder
{
    if( (self = [super init]) )
    {
        _target = [aDecoder decodeObjectForKey:@"target"];
        _previousParent = [aDecoder decodeObjectForKey:@"previousParent"];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.target forKey:@"target"];
    [aCoder encodeObject:self.previousParent forKey:@"previousParent"];
}

@end

static FCGameState *instance = nil;
// static dispatch_once_t ot = 0L;


@implementation FCGameState

+ (FCGameState *) shared
{
//    dispatch_once(&ot, ^{
//        instance = [[self alloc] init];
//        [instance initialize];
//    });
    if( instance == nil )
    {
        instance = [[self alloc] init];
        [instance initialize];
    }
    return instance;
}

- (void) initialize
{
    self.movesStack = [NSMutableArray new];
    
    if( self.cardSep == nil )
    {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsKeyCardSeparations];
        if( data != nil )
        {
            self.cardSep = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }
        else
        {
            self.cardSep = [[NSMutableArray alloc] initWithCapacity:8];
        
            for( int i = 0; i < 8; i++ )
            {
                [self.cardSep addObject:@28.F];
            }
        }
    }
    
    if( self.cardsArray == nil )
    {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsKeySavedCardsState];
        if( data != nil )
        {
            self.cardsArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }
    }
    
    if( self.cardsSlots == nil )
    {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsKeySavedCardsSlots];
        if( data != nil )
        {
            self.cardsSlots = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }
    }
    
    if( self.gameSlots == nil )
    {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefatulsKeySavedGameSlots];
        if( data != nil )
        {
            self.gameSlots = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }
    }
    
    if( self.freeCellSlots == nil )
    {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsKeySavedFreeCellSlots];
        if( data != nil )
        {
            self.freeCellSlots = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }
    }
}

- (CGFloat) separationForColumn:(NSInteger)column
{
    CGFloat ret = 0.F;
    
    if( column >= 0 && column < 8 )
    {
        ret = [self.cardSep[column] floatValue];
    }
    return ret;
}

- (void) setSeparation:(CGFloat)separation forColumn:(NSInteger)column
{
    NSNumber *number = @(separation);
    [self.cardSep setObject:number atIndexedSubscript:column];
}

- (FCCard *) cardWithName:(NSString *)name
{
    FCCard *retCard = nil;
    
    for( FCCard *card in self.cardsArray )
    {
        if( [card.name isEqualToString:name] )
        {
            retCard = card;
            break;
        }
    }
    return retCard;
}

- (BOOL) possibleChildsAlreadyStackedForCard:(FCCard *)card
{
    BOOL bRet = NO;
    
    FCCardSuit checkSuits[2] = {FCCardSuitSpade, FCCardSuitClub};
    if( card.isRed == NO )
    {
        checkSuits[0] = FCCardSuitHeart;
        checkSuits[1] = FCCardSuitDiamond;
    }
    
    FCCard *child1 = [self cardWithSuit:checkSuits[0] andNumber:card.number-1];
    FCCard *child2 = [self cardWithSuit:checkSuits[1] andNumber:card.number-1];
    
    if( child1.stacked && child2.stacked )
    {
        bRet = YES;
    }
    
    return bRet;
}

- (FCCard *) cardWithSuit:(FCCardSuit)suit andNumber:(FCCardNumber)number
{
    FCCard *retCard = nil;
    
    for( FCCard *card in self.cardsArray )
    {
        if( card.suit == suit && card.number == number )
        {
            retCard = card;
            break;
        }
    }
    return retCard;
}

- (void) saveState
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.cardsArray];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kUserDefaultsKeySavedCardsState];
    
    data = [NSKeyedArchiver archivedDataWithRootObject:self.gameSlots];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kUserDefatulsKeySavedGameSlots];
    
    data = [NSKeyedArchiver archivedDataWithRootObject:self.freeCellSlots];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kUserDefaultsKeySavedFreeCellSlots];
    
    data = [NSKeyedArchiver archivedDataWithRootObject:self.cardsSlots];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kUserDefaultsKeySavedCardsSlots];
    
    data = [NSKeyedArchiver archivedDataWithRootObject:self.cardSep];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kUserDefaultsKeyCardSeparations];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) resetState
{
    [self resetUndoStack];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultsKeySavedCardsState];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefatulsKeySavedGameSlots];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultsKeySavedFreeCellSlots];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultsKeySavedCardsSlots];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultsKeyCardSeparations];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL) restoreState
{
    [self initialize];
    return YES;
}

- (void) addMoveWithTargetCard:(FCCard *)targetCard andPreviousParent:(FCSpriteNode *)previousParent
{
    if( targetCard && previousParent )
    {
        FCMove *move = [FCMove new];
        move.target = targetCard;
        move.previousParent = previousParent;
        
        if( self.movesStack.count < kMaxUndoActions )
        {
            [self.movesStack addObject:move];
        }
        else
        {
            NSMutableArray *ma = [NSMutableArray new];
            for( NSInteger i = 1; i < kMaxUndoActions; i++ )
            {
                [ma addObject:self.movesStack[i]];
            }
            [ma addObject:move];
            self.movesStack = ma;
        }
    }
#ifdef DEBUG
    else
    {
        NSLog(@"WARNING: %s -> Attempting to insert nil target (%p) or previousParent (%p).", __FUNCTION__, targetCard, previousParent);
    }
#endif
}

- (FCMove *) consumLastMove
{
    FCMove *move = [self.movesStack lastObject];
    [self.movesStack removeLastObject];
    return move;
}

- (BOOL) undoAvailable
{
    return self.movesStack.count > 0;
}

- (void) resetUndoStack
{
    [self.movesStack removeAllObjects];
}

- (void) printSlots:(FCSlotType)type
{
    NSArray *slotsArray = nil;
    
    switch( type )
    {
        case FCSlotTypeGame:      slotsArray = _gameSlots; break;
        case FCSlotTypeFreeCell:  slotsArray = _freeCellSlots; break;
        case FCSlotTypeSuitStack: slotsArray = _cardsSlots; break;
    };
    
    NSLog(@"\n\n\n         PRINT %@ SLOTS", [slotsArray[0] stringFromType]);
    for( FCSlot *slot in slotsArray )
    {
        NSLog(@"-----------------------------------------");
        NSLog(@"%@\n", slot);
    }
}

@end

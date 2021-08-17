//
//  FCGameState.m
//  iFreeCell
//
//  Created by Miguel Estévez on 23/08/16.
//  Copyright (c) 2013 Miguel Estévez. All rights reserved.
//

#import "FCGameState.h"
#import "FCCard.h"

#define kUserDefaultsKeySavedCardsState     @"UserDefaultsSavedCardsState"
#define kUserDefaultsKeySavedFreeCellSlots  @"UserDefaultsSavedFreeCellSlots"
#define kUserDefatulsKeySavedGameSlots      @"UserDefaultsSavedGameSlots"
#define kUserDefaultsKeySavedCardsSlots     @"UserDefaultsSavedCardsSlots"
#define kUserDefaultsKeyCardSeparations     @"UserDefaultsCardSeparations"
#define kUserDefaultsKeyGameNumber          @"UserDefaultsGameNumber"
#define kUserDefaultsKeyAutoStack           @"UserDefaultsAutoStack"
#define kUserDefaultsKeyNumberOfPlayedGames @"UserDefaultsNumberOfPlayedGames"
#define kUserDefaultsKeyNumberOfWins        @"UserDefaultsNumberOfWins"
#define kUserDefaultsKeyStatisticsDate      @"UserDefaultsStatisticsDate"


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

@interface FCGameState()
{
    NSInteger _zPositionMove;
}
@end

@implementation FCGameState

+ (FCGameState *) shared
{
//    dispatch_once(&ot, ^{
//        instance = [[self alloc] init];
//        [instance initialize];
//    });
//    return instance;
    
    //*
    @synchronized (self)
    {
        if( instance == nil )
        {
            instance = [[self alloc] init];
            [instance initialize];
        }
    }
    return instance;
     //*/
}

- (void) initialize
{
    NSError *error = nil;
    
    if( self.cardSep == nil )
    {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsKeyCardSeparations];
        if( data != nil )
        {
            // self.cardSep = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            self.cardSep = [NSKeyedUnarchiver unarchivedArrayOfObjectsOfClass:[NSNumber class] fromData:data error:&error].mutableCopy;
            if( error ) [self traceError:error withTitle:@"Unarchive cardsArray"];
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
    
    NSSet *classesSet = [NSSet setWithArray:@[[NSMutableArray class], [FCCard class], [FCSlot class]]];
    
    if( self.cardsArray == nil )
    {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsKeySavedCardsState];
        if( data != nil )
        {
            // self.cardsArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            self.cardsArray = ((NSMutableArray *)[NSKeyedUnarchiver unarchivedObjectOfClasses:classesSet fromData:data error:&error]).mutableCopy;
            if( error ) [self traceError:error withTitle:@"Unarchive cardsArray"];
        }
        else
        {
            self.cardsArray = [NSMutableArray arrayWithCapacity:52];
        }
    }
    
    if( self.cardsSlots == nil )
    {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsKeySavedCardsSlots];
        if( data != nil )
        {
            // self.cardsSlots = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            self.cardsSlots = ((NSMutableArray *)[NSKeyedUnarchiver unarchivedObjectOfClasses:classesSet fromData:data error:&error]).mutableCopy;
            if( error ) [self traceError:error withTitle:@"Unarchive cardsSlot"];
        }
        else
        {
            self.cardsSlots = [NSMutableArray arrayWithCapacity:4];
        }
    }
    
    if( self.gameSlots == nil )
    {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefatulsKeySavedGameSlots];
        if( data != nil )
        {
            // self.gameSlots = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            self.gameSlots = ((NSMutableArray *)[NSKeyedUnarchiver unarchivedObjectOfClasses:classesSet fromData:data error:&error]).mutableCopy;
            if( error ) [self traceError:error withTitle:@"Unarchive gameSlots"];
        }
        else
        {
            self.gameSlots = [NSMutableArray arrayWithCapacity:8];
        }
    }
    
    if( self.freeCellSlots == nil )
    {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsKeySavedFreeCellSlots];
        if( data != nil )
        {
            // self.freeCellSlots = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            self.freeCellSlots = ((NSMutableArray *)[NSKeyedUnarchiver unarchivedObjectOfClasses:classesSet fromData:data error:&error]).mutableCopy;
            if( error ) [self traceError:error withTitle:@"Unarchive freeCellSlots"];
        }
        else
        {
            self.freeCellSlots = [NSMutableArray arrayWithCapacity:4];
        }
    }
 
    self.movesStack = [NSMutableArray new];
 
    if( [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsKeyAutoStack] == nil )
        self.autoStack = YES;
    
    self.gameNumber = [[[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsKeyGameNumber] intValue];
}

- (BOOL) autoStack
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsKeyAutoStack];
}

- (NSInteger) zPositionMoveIncrement:(BOOL)increment
{
    if( _zPositionMove == 0 ) _zPositionMove = kZPositionMove;
    if( increment) _zPositionMove += 1;
    return _zPositionMove;
}

- (NSInteger) zPositionMove
{
    return [self zPositionMoveIncrement:YES];
}

- (void) resetZPositionMove
{
    _zPositionMove = 0;
}

- (void) setAutoStack:(BOOL)autoStack
{
    [[NSUserDefaults standardUserDefaults] setBool:autoStack forKey:kUserDefaultsKeyAutoStack];
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
    NSError *error = nil;
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.cardSep requiringSecureCoding:YES error:&error];
    if( error ) [self traceError:error withTitle:@"save data CARDSEP"];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kUserDefaultsKeyCardSeparations];
    
    data = [NSKeyedArchiver archivedDataWithRootObject:self.cardsArray requiringSecureCoding:NO error:&error];
    if( error ) [self traceError:error withTitle:@"save data CARDSARRAY"];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kUserDefaultsKeySavedCardsState];
    
    data = [NSKeyedArchiver archivedDataWithRootObject:self.gameSlots requiringSecureCoding:NO error:&error];
    if( error ) [self traceError:error withTitle:@"save data GAMESLOTS"];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kUserDefatulsKeySavedGameSlots];
    
    data = [NSKeyedArchiver archivedDataWithRootObject:self.freeCellSlots requiringSecureCoding:NO error:&error];
    if( error ) [self traceError:error withTitle:@"save data FREECELLSOLTS"];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kUserDefaultsKeySavedFreeCellSlots];
    
    data = [NSKeyedArchiver archivedDataWithRootObject:self.cardsSlots requiringSecureCoding:NO error:&error];
    if( error ) [self traceError:error withTitle:@"save data CARDSLOTS"];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kUserDefaultsKeySavedCardsSlots];
    
    [[NSUserDefaults standardUserDefaults] setObject:@(self.gameNumber) forKey:kUserDefaultsKeyGameNumber];
    NSLog(@"-------> SAVE STATE program complete!");
}

- (void) resetState
{
    [self resetUndoStack];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultsKeySavedCardsState];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefatulsKeySavedGameSlots];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultsKeySavedFreeCellSlots];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultsKeySavedCardsSlots];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultsKeyCardSeparations];
    
    for( SKSpriteNode *node in _cardsSlots )
    {
        [node removeFromParent];
    }
    
    for( SKSpriteNode *node in _cardsArray )
    {
        [node removeFromParent];
    }
    
    for( SKSpriteNode *node in _freeCellSlots )
    {
        [node removeFromParent];
    }
    
    for( SKSpriteNode *node in _gameSlots )
    {
        [node removeFromParent];
    }
    
    [_freeCellSlots removeAllObjects];
    [_cardsSlots removeAllObjects];
    [_gameSlots removeAllObjects];
    [_cardsArray removeAllObjects];
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


#pragma mark - Statistics

- (void) addGameToStatistics
{
    NSNumber *number = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsKeyNumberOfPlayedGames];
    NSInteger integer;
    if( number ) integer = number.integerValue + 1;
    else integer = 1;
    [[NSUserDefaults standardUserDefaults] setObject:@(integer) forKey:kUserDefaultsKeyNumberOfPlayedGames];
}

- (void) addWinToStatistics
{
    NSNumber *number = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsKeyNumberOfWins];
    NSInteger integer;
    if( number ) integer = number.integerValue + 1;
    else integer = 1;
    [[NSUserDefaults standardUserDefaults] setObject:@(integer) forKey:kUserDefaultsKeyNumberOfWins];
}

- (NSInteger) getNumberOfPlayedGames
{
    NSNumber *number = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsKeyNumberOfPlayedGames];
    if( number ) return number.integerValue;
    else return 0;
}

- (NSInteger) getNumberOfWins
{
    NSNumber *number = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsKeyNumberOfWins];
    if( number ) return number.integerValue;
    else return 0;
}

- (NSDate *) statisticsDate
{
    NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsKeyStatisticsDate];
    if( date )
    {
        return date;
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kUserDefaultsKeyStatisticsDate];
        return [NSDate date];
    }
}

- (void) resetStatistics
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kUserDefaultsKeyStatisticsDate];
    [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:kUserDefaultsKeyNumberOfPlayedGames];
    [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:kUserDefaultsKeyNumberOfWins];
}

- (NSString *) statisticsDateString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMM dd YYYY";
    NSDate *date = self.statisticsDate;
    NSInteger days = [self daysBetweenDate:date andDate:[NSDate date]];
    NSString *dayString = days == 1 ? @"day" : @"days";
    
    return [NSString stringWithFormat:@"%@ (%ld %@)",
            [formatter stringFromDate:date], days, dayString];
}


- (NSInteger) daysBetweenDate:(NSDate *)fromDateTime andDate:(NSDate *)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;

    NSCalendar *calendar = [NSCalendar currentCalendar];

    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
        interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
        interval:NULL forDate:toDateTime];

    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
        fromDate:fromDate toDate:toDate options:0];

    return [difference day];
}

#pragma mark - Trace & debug

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

- (void) traceError:(NSError *)error withTitle:(NSString *)title
{
    NSLog(@"------> %@: %@", title.uppercaseString, error.localizedDescription);
}

@end

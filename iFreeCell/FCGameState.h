//
//  FCGameState.h
//  iFreeCell
//
//  Created by Miguel Estévez on 23/08/16.
//  Copyright (c) 2013 Miguel Estévez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FCSlot.h"
#import "FCCard.h"

#define kMaxUndoActions     6

@interface FCMove : NSObject <NSCoding>
{}
@property (nonatomic, strong) FCCard *target;
@property (nonatomic, strong) FCSpriteNode *previousParent;
@end

@interface FCGameState : NSObject
{
}

@property (nonatomic, strong) NSMutableArray <FCCard *> *cardsArray;
@property (nonatomic, strong) NSMutableArray <FCSlot *> *freeCellSlots;
@property (nonatomic, strong) NSMutableArray <FCSlot *> *cardsSlots;
@property (nonatomic, strong) NSMutableArray <FCSlot *> *gameSlots;

@property (nonatomic, readonly, assign) NSInteger zPositionMove;

@property (nonatomic, strong) NSMutableArray <NSNumber *> *cardSep;

@property (nonatomic, strong) NSMutableArray <FCMove *> *movesStack;

@property (nonatomic, assign) NSInteger gameNumber;
@property (nonatomic, assign) BOOL autoStack;
@property (nonatomic, assign) NSInteger backgroundColorIndex;
@property (nonatomic, strong) NSDate *statisticsDate;


+ (FCGameState *) shared;
- (void) saveState;
- (BOOL) restoreState;
- (void) resetState;

- (void) resetZPositionMove;
- (NSInteger) zPositionMoveIncrement:(BOOL)increment;

- (CGFloat) separationForColumn:(NSInteger)column;
- (void) setSeparation:(CGFloat)separation forColumn:(NSInteger)column;


- (FCCard *) cardWithName:(NSString *)name;
- (FCCard *) cardWithSuit:(FCCardSuit)suit andNumber:(FCCardNumber)number;
- (BOOL) possibleChildsAlreadyStackedForCard:(FCCard *)card;

- (void) addMoveWithTargetCard:(FCCard *)targetCard andPreviousParent:(FCSpriteNode *)previousParent;
- (FCMove *) consumLastMove;
- (BOOL) undoAvailable;
- (void) resetUndoStack;

- (void) addGameToStatistics;
- (void) addWinToStatistics;
- (NSInteger) getNumberOfPlayedGames;
- (NSInteger) getNumberOfWins;
- (void) resetStatistics;
- (NSString *) statisticsDateString;

- (void) printSlots:(FCSlotType)type;

- (SKColor *)backgroundColor;

@end


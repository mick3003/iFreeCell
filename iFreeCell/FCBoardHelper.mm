//
//  FCBoardHelper.m
//  iFreeCell
//
//  Created by Miguel Estévez on 06/08/16.
//  Copyright (c) 2013 Miguel Estévez. All rights reserved.
//  change 1

#import "FCBoardHelper.h"
#import "AFreecellGameBoard.h"

@implementation FCBoardHelper

- (NSString *) newBoardForSeed:(NSInteger) seed
{
    NSLog(@"NEW BOARD with seed %ld", seed);
    
    NSString *retStr = nil;
    
    char *cstr = getNewBoardString( (int)seed );
    
    if( cstr != NULL )
    {
        retStr = [NSString stringWithCString:cstr encoding:NSUTF8StringEncoding];
    }
    return retStr;
}

@end

//
//  FCBoardHelper.m
//  iFreeCell
//
//  Created by Miguel Estévez on 06/08/13.
//  Copyright (c) 2013 Miguel Estévez. All rights reserved.
//

#import "FCBoardHelper.h"
#import "AFreecellGameBoard.h"

@implementation FCBoardHelper

- (NSString *) newBoardForSeed:(NSInteger) seed
{
    NSString *retStr = nil;
    
    char *cstr = getNewBoardString( (int)seed );
    
    if( cstr != NULL )
    {
        retStr = [NSString stringWithCString:cstr encoding:NSUTF8StringEncoding];
    }
    return retStr;
}

@end

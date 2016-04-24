//
//  NSMutableArray+ContactNodes.m
//  iFreeCell
//
//  Created by Miguel Estévez on 08/08/14.
//  Copyright (c) 2014 Miguel Estévez. All rights reserved.
//

#import "NSMutableArray+ContactNodes.h"

@implementation NSMutableArray (ContactNodes)

- (void) addObjectOnce:(id)object
{
    if( [self indexOfObject:object] == NSNotFound )
    {
        [self addObject:object];
    }
}

@end

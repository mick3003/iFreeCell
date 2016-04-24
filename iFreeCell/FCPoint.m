//
//  FCPoint.m
//  iFreeCell
//
//  Created by Miguel Estévez on 18/08/13.
//  Copyright (c) 2013 Miguel Estévez. All rights reserved.
//

#import "FCPoint.h"

@implementation FCPoint

+ (id) point
{
    return [self pointWithCGPoint:CGPointZero];
}

+ (id) pointWithCGPoint:(CGPoint) cgPoint
{
    return [[self alloc] initWithX:cgPoint.x Y:cgPoint.y];
}

+ (id) pointWithX:(CGFloat)px Y:(CGFloat)py
{
    return [[self alloc] initWithX:px Y:py];
}

- (id) initWithX:(CGFloat)px Y:(CGFloat)py
{
    self = [super init];
    
    if( self != nil )
    {
        _x = px;
        _y = py;
    }
    return self;
}

+ (NSString *) printCGPoint:(CGPoint)point
{
    return [NSString stringWithFormat:@"(%f, %f)", point.x, point.y];
}

- (CGPoint) cgPoint
{
    return CGPointMake(_x, _y);
}

- (CGFloat) distanceFromPoint:(const FCPoint *)pPoint
{
    return sqrtf( powf(_x - pPoint.x, 2) + pow(_y - pPoint.y, 2) );
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"FCPoint = %p | point = (%f, %f)", self, _x, _y];
}

@end

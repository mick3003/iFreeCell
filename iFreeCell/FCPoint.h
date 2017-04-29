//
//  FCPoint.h
//  iFreeCell
//
//  Created by Miguel Estévez on 18/08/16.
//  Copyright (c) 2013 Miguel Estévez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FCPoint : NSObject
{
    
}

@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;

+ (id) point;
+ (id) pointWithCGPoint:(CGPoint) cgPoint;
+ (id) pointWithX:(CGFloat)px Y:(CGFloat)py;
+ (NSString *) printCGPoint:(CGPoint)point;
- (CGFloat) distanceFromPoint:(const FCPoint *) point;

@end

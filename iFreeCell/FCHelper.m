//
//  FCHelper.m
//  iFreeCell
//
//  Created by Miguel Estévez on 28/08/16.
//  Copyright (c) 2013 Miguel Estévez. All rights reserved.
//

#import "FCHelper.h"

@implementation FCHelper

+ (BOOL) cgRect:(CGRect)r1 touchesCGRect:(CGRect)r2
{
    BOOL bRet = NO;
    
    CGFloat r1x0, r1x1, r1y0, r1y1, r2x0, r2x1, r2y0, r2y1;
    
    r1x0 = r1.origin.x;
    r1x1 = r1.origin.x + r1.size.width;
    r1y0 = r1.origin.y;
    r1y1 = r1.origin.y + r1.size.height;
    
    r2x0 = r2.origin.x;
    r2x1 = r2.origin.x + r2.size.width;
    r2y0 = r2.origin.y;
    r2y1 = r2.origin.y + r2.size.height;
    
    if( (r1x0 > r2x0 && r1x0 < r2x1) || (r1x1 > r2x0 && r1x1 < r2x1) )
    {
        if( (r1y0 > r2y0 && r1y0 < r2y1) || (r1y1 > r2y0 && r1y1 < r2y1) )
        {
            bRet = YES;
        }
    }
    
    return bRet;
}

+ (NSInteger) randomGameNumber
{
    return [self randomNumberBetween:1 maxNumber:65535];
}

+ (NSInteger) randomNumberBetween:(NSInteger)min maxNumber:(NSInteger)max
{
    return min + arc4random_uniform((uint32_t)(max - min + 1));
}

+ (NSInteger) intFromString:(NSString *)string
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *number = [formatter numberFromString:string];
    return number.integerValue;
}

@end

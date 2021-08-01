//
//  FCHelper.h
//  iFreeCell
//
//  Created by Miguel Estévez on 28/08/16.
//  Copyright (c) 2013 Miguel Estévez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FCHelper : NSObject
{
    
}

+ (BOOL) cgRect:(CGRect)r1 touchesCGRect:(CGRect)r2;
+ (NSInteger) randomGameNumber;
+ (NSInteger) randomNumberBetween:(NSInteger)min maxNumber:(NSInteger)max;
+ (NSInteger) intFromString:(NSString *)string;
+ (BOOL) isRoundedDisplay;

@end

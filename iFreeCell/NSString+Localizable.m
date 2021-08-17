//
//  NSString+Localizable.m
//  iFreeCell
//
//  Created by Miguel Estévez on 17/8/21.
//  Copyright © 2021 Miguel Estévez. All rights reserved.
//

#import "NSString+Localizable.h"

@implementation NSString (Localizable)

- (NSString *) localized
{
    return NSLocalizedStringFromTable(self, nil, nil);
}

@end

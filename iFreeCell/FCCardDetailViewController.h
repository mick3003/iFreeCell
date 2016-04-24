//
//  FCCardDetailViewController.h
//  iFreeCell
//
//  Created by Miguel Estévez on 10/4/16.
//  Copyright © 2016 Miguel Estévez. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FCCard;
@class FCSlot;

@interface FCCardDetailViewController : UIViewController

@property (nonatomic, weak) FCCard *card;
@property (nonatomic, weak) FCSlot *slot;
@property (nonatomic, assign) CGFloat showingZPosition;

@end

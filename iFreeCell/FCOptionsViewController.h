//
//  FCMiscViewController.h
//  iFreeCell
//
//  Created by Miguel Estévez on 5/8/21.
//  Copyright © 2021 Miguel Estévez. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FCOptionsViewController;

@protocol FCOptionsViewControllerDelegate <NSObject>
@required
- (void) optionsViewControllerDidOpen:(FCOptionsViewController *) optionsViewController;
- (void) optionsViewController:(FCOptionsViewController *)optionsViewController tappedButtonAtIndex:(NSInteger)index;
@end

@interface FCOptionsViewController : UIViewController
{
}

@property (nonatomic, weak) id <FCOptionsViewControllerDelegate> delegate;

@end

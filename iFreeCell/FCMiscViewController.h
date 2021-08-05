//
//  FCMiscViewController.h
//  iFreeCell
//
//  Created by Miguel Estévez on 5/8/21.
//  Copyright © 2021 Miguel Estévez. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FCMiscViewController;

@protocol FCMiscViewControllerDelegate <NSObject>
@required
- (void) miscViewControllerDidOpen:(FCMiscViewController *) miscViewController;
- (void) miscViewController:(FCMiscViewController *)miscViewController tappedButtonAtIndex:(NSInteger)index;
@end

@interface FCMiscViewController : UIViewController
{
}

@property (nonatomic, weak) id <FCMiscViewControllerDelegate> delegate;

@end

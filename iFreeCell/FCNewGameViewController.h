//
//  FCNewGameViewController.h
//  iFreeCell
//
//  Created by Miguel Estévez on 29/3/16.
//  Copyright © 2016 Miguel Estévez. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FCNewGameViewController;

@protocol FCNewGameControllerDelegate <NSObject>
@required
- (void) newGameViewController:(FCNewGameViewController *)newGameViewController finishWithGameNumber:(NSInteger)gameNumber;
- (void) newGameViewControllerDidOpen:(FCNewGameViewController *)newGameViewController;
- (void) newGameViewControllerWillClose:(FCNewGameViewController *)newGameViewController;
@end

@interface FCNewGameViewController : UIViewController
{
}

@property (nonatomic, weak) id <FCNewGameControllerDelegate> delegate;

@end

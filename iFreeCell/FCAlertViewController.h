//
//  FCAlertViewController.h
//  iFreeCell
//
//  Created by Miguel Estévez on 29/4/17.
//  Copyright © 2017 Miguel Estévez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCHelper.h"

@class FCAlertViewController;

@protocol FCAlertViewControllerDelegate <NSObject>
@required
- (void) alertViewController:(FCAlertViewController *)alertViewController tappedButtonAtIndex:(NSInteger)index;
@end

@interface FCAlertViewController : UIViewController
{
}

@property (nonatomic, weak) id <FCAlertViewControllerDelegate> delegate;
@property (nonatomic, assign) FCModalAction modalAction;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSArray *buttonTitles;

- (void) close;

@end

//
//  FCMiscViewController.m
//  iFreeCell
//
//  Created by Miguel Estévez on 5/8/21.
//  Copyright © 2021 Miguel Estévez. All rights reserved.
//

#import "FCMiscViewController.h"
#import "FCGameState.h"


@interface FCMiscViewController ()
{
}

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
 
@end


@implementation FCMiscViewController

- (id) initWithCoder:(NSCoder *)aDecoder
{
    if( self = [super initWithCoder:aDecoder] )
    {
        self.modalPresentationStyle = UIModalPresentationCustom;
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.contentView.clipsToBounds = YES;
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentView.layer.cornerRadius = 15.F;
    self.closeButton.layer.cornerRadius = 10.F;
    self.view.backgroundColor = [UIColor clearColor];
    
    [self.delegate miscViewControllerDidOpen:self];
}


#pragma mark - Actions implementation

- (IBAction) closeButtonTapped:(UIButton *)sender
{
    NSLog(@"%s", __FUNCTION__);
    [self close];
}

- (void) close
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end

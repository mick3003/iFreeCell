//
//  FCAlertViewController.m
//  iFreeCell
//
//  Created by Miguel Estévez on 29/4/17.
//  Copyright © 2017 Miguel Estévez. All rights reserved.
//

#import "FCAlertViewController.h"

@interface FCAlertViewController ()
{
}

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIButton *button1;
@property (weak, nonatomic) IBOutlet UIButton *button2;

@end

@implementation FCAlertViewController

- (id) initWithCoder:(NSCoder *)aDecoder
{
    if( self = [super initWithCoder:aDecoder] )
    {
        self.modalPresentationStyle = UIModalPresentationCustom;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.contentView.clipsToBounds = YES;
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentView.layer.cornerRadius = 15.F;
    
    self.button1.layer.cornerRadius =
    self.button2.layer.cornerRadius = 10.F;
    
    self.view.backgroundColor = [UIColor clearColor];
    
    if( self.buttonTitles.count == 1 )
    {
        [self.button1 setTitle:self.buttonTitles[0] forState:UIControlStateNormal];
        [self.button2 removeFromSuperview];
    }
    else if( self.buttonTitles.count == 2 )
    {
        [self.button1 setTitle:self.buttonTitles[0] forState:UIControlStateNormal];
        [self.button2 setTitle:self.buttonTitles[1] forState:UIControlStateNormal];
    }
    
    if( self.message )
    {
        self.messageLabel.text = self.message;
    }
}

- (IBAction) buttonTapped:(UIButton *)sender
{
    [self.delegate alertViewController:self tappedButtonAtIndex:sender.tag];
    [self close];
}

- (IBAction) backgroundButtonTapped:(id)sender
{
    [self close];
}

- (void) close
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end

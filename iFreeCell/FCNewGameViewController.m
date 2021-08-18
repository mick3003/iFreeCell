//
//  FCNewGameViewController.m
//  iFreeCell
//
//  Created by Miguel Estévez on 29/3/16.
//  Modified by Miguel Estévez on 01/08/2021.
//
//  Copyright © 2016 Miguel Estévez. All rights reserved.
//

#import "FCNewGameViewController.h"

@interface FCNewGameViewController ()

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *randomButton;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *tfView;

@end

@implementation FCNewGameViewController

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
    
    self.okButton.layer.cornerRadius =
    self.cancelButton.layer.cornerRadius =
    self.randomButton.layer.cornerRadius = 10.F;
    
    self.tfView.layer.cornerRadius = 5.F;
    self.tfView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.tfView.layer.borderWidth = .5F;
    
    self.view.backgroundColor = [UIColor clearColor];
    
    [self.randomButton setTitle:@"Random".localized forState:UIControlStateNormal];
    [self.okButton setTitle:@"OK".localized forState:UIControlStateNormal];
    [self.cancelButton setTitle:@"Cancel".localized forState:UIControlStateNormal];
    
    self.titleLabel.text = @"Select new game number (0 - 65535):".localized;
    
    [self.delegate newGameViewControllerDidOpen:self];
}

- (IBAction) cancelButtonTapped:(id)sender
{
    [self close];
}

- (IBAction) okButtonTapped:(id)sender
{
    NSInteger gameNumber = [FCHelper intFromString:self.textField.text];
    
    if( gameNumber < 1 || gameNumber > 65535 )
    {
        // Invalid number or input
        return;
    }
    
    [[FCGameState shared] addGameToStatistics];
    [self.delegate newGameViewController:self finishWithGameNumber:gameNumber];
    [self close];
}

- (IBAction) randomButtonTapped:(id)sender
{
    NSInteger random = [FCHelper randomGameNumber];
    self.textField.text = [NSString stringWithFormat:@"%ld", random];
}

- (IBAction) tfDidEndOnExit:(UITextField *)sender
{
    [sender resignFirstResponder];
}

- (IBAction) backgroundButtonTapped:(id)sender
{
    [self close];
}

- (void) close
{
    [self dismissViewControllerAnimated:YES completion:^{}];
    [self.delegate newGameViewControllerWillClose:self];
}

@end

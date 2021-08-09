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
@property (weak, nonatomic) IBOutlet UISwitch *autoStackSwitch;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
 
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
    
    self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    
    self.contentView.clipsToBounds = YES;
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentView.layer.cornerRadius = 15.F;
    self.closeButton.layer.cornerRadius = 10.F;
    self.resetButton.layer.cornerRadius = 10.F;
    self.view.backgroundColor = [UIColor clearColor];
    self.autoStackSwitch.on = [[FCGameState shared] autoStack];
    
    [self drawStatisticsTable];
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

- (IBAction) autoStackSwitchValueChanged:(UISwitch *)sender
{
    [[FCGameState shared] setAutoStack:sender.isOn];
}

- (IBAction) resetButtonTapped:(id)sender
{
    
}


#pragma mark - Private methods

- (void) drawStatisticsTable
{
    for( NSInteger i = 1; i < 10; i++ )
    {
        UIView *view = [self.view viewWithTag:i];
        view.layer.borderColor = [UIColor lightGrayColor].CGColor;
        view.layer.borderWidth = .5F;
    }
}

@end

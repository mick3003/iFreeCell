//
//  FCNewGameViewController.m
//  iFreeCell
//
//  Created by Miguel Estévez on 29/3/16.
//  Copyright © 2016 Miguel Estévez. All rights reserved.
//

#import "FCNewGameViewController.h"

@interface FCNewGameViewController ()

@property (weak, nonatomic) IBOutlet UIView *contentView;

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

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.contentView.clipsToBounds = YES;
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentView.layer.cornerRadius = 15.F;
    
    self.view.backgroundColor = [UIColor clearColor];
}

- (IBAction) buttonTapped:(id)sender
{
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

//
//  FCMiscViewController.m
//  iFreeCell
//
//  Created by Miguel Estévez on 5/8/21.
//  Copyright © 2021 Miguel Estévez. All rights reserved.
//

#import "FCOptionsViewController.h"
#import "FCGameState.h"


@interface FCOptionsViewController ()
{
}

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UISwitch *autoStackSwitch;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *gamesLabel;
@property (weak, nonatomic) IBOutlet UILabel *wonLabel;
@property (weak, nonatomic) IBOutlet UILabel *lostLabel;
    
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *autoLabel;
@property (weak, nonatomic) IBOutlet UILabel *sinceStLabel;
@property (weak, nonatomic) IBOutlet UILabel *playedStLabel;
@property (weak, nonatomic) IBOutlet UILabel *wonStLabel;
@property (weak, nonatomic) IBOutlet UILabel *lostStLabel;

 
@end


@implementation FCOptionsViewController

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
    
    self.titleLabel.text = @"A simple FreeCell game for iPad".localized;
    self.subtitleLabel.text = @"Game statistics:".localized;
    self.autoLabel.text = @"Auto stack cards".localized;
    self.sinceStLabel.text = @"Statistics since".localized;
    self.playedStLabel.text = @"Games played".localized;
    self.wonStLabel.text = @"Games won".localized;
    self.lostStLabel.text = @"Games lost".localized;
    
    [self.resetButton setTitle:@"Reset".localized forState:UIControlStateNormal];
    [self.closeButton setTitle:@"CLOSE".localized forState:UIControlStateNormal];
    
    [self drawStatisticsTable];
    
    [self.delegate optionsViewControllerDidOpen:self];
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

- (IBAction) resetButtonTapped:(UIButton *)sender
{
    if( [[[sender titleLabel] text] isEqualToString:@"Reset".localized] )
    {
        [sender setTitle:@"Sure?".localized forState:UIControlStateNormal];
    }
    else
    {
        [[FCGameState shared] resetStatistics];
        [sender setTitle:@"Reset".localized forState:UIControlStateNormal];
        [self drawStatisticsTable];
    }
}


#pragma mark - Private methods

- (void) drawStatisticsTable
{
    for( NSInteger i = 1; i < 9; i++ )
    {
        UIView *view = [self.view viewWithTag:i];
        view.layer.borderColor = [UIColor lightGrayColor].CGColor;
        view.layer.borderWidth = .5F;
    }
    
    CGFloat playedGames = [[FCGameState shared] getNumberOfPlayedGames];
    CGFloat wonGames = [[FCGameState shared] getNumberOfWins];
    CGFloat lostGames = playedGames-wonGames;
    
    CGFloat percWon = playedGames == 0? 0: wonGames / playedGames * 100.F;
    CGFloat percLost = playedGames == 0? 0: lostGames / playedGames * 100.F;
    
    self.dateLabel.text = [[FCGameState shared] statisticsDateString];
    self.gamesLabel.text = [NSString stringWithFormat:@"%.0f", playedGames];
    self.wonLabel.text = [NSString stringWithFormat:@"%.0f (%.0f%%)", wonGames, percWon];
    self.lostLabel.text = [NSString stringWithFormat:@"%.0f (%.0f%%)", playedGames-wonGames, percLost];
}

@end

//
//  FCMiscViewController.m
//  iFreeCell
//
//  Created by Miguel Estévez on 5/8/21.
//  Copyright © 2021 Miguel Estévez. All rights reserved.
//

#import "FCOptionsViewController.h"
#import "FCGameState.h"
#import "FCGameScene.h"
#import "FCGameScene+MainMenu.h"


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
@property (weak, nonatomic) IBOutlet UILabel *bgColorLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *bgColorSegmentedControl;

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
    self.bgColorLabel.text = @"Background color".localized;

    [self.resetButton setTitle:@"Reset".localized forState:UIControlStateNormal];
    [self.closeButton setTitle:@"CLOSE".localized forState:UIControlStateNormal];
    
    self.bgColorSegmentedControl.selectedSegmentIndex = [[FCGameState shared] backgroundColorIndex];
    self.bgColorSegmentedControl.tintColor = [UIColor clearColor];
    [self setupColorSegments];
    
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

- (IBAction) bgColorSegmentedControlValueChanged:(UISegmentedControl *)sender
{
    [[FCGameState shared] setBackgroundColorIndex:sender.selectedSegmentIndex];
    [self.gameScene updateBackgroundColor];
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

- (void) setupColorSegments
{
    NSArray<UIColor *> *colors = @[
        [UIColor colorWithRed:30.F/255.F green:153.F/255.F blue:199.F/255.F alpha:1.F],
        [UIColor colorWithRed:20.F/255.F green:20.F/255.F blue:20.F/255.F alpha:1.F],
        [UIColor colorWithRed:34.F/255.F green:120.F/255.F blue:60.F/255.F alpha:1.F],
        [UIColor colorWithRed:120.F/255.F green:60.F/255.F blue:30.F/255.F alpha:1.F],
        [UIColor colorWithRed:60.F/255.F green:60.F/255.F blue:120.F/255.F alpha:1.F],
    ];
    
    for( NSInteger i = 0; i < colors.count; i++ )
    {
        [self.bgColorSegmentedControl setImage:[self imageWithColor:colors[i] size:CGSizeMake(24.F, 24.F)] forSegmentAtIndex:i];
    }
}

- (UIImage *) imageWithColor:(UIColor *)color size:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.F);
    CGRect rect = CGRectMake(0.F, 0.F, size.width, size.height);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(rect, 1.F, 1.F)];
    [color setFill];
    [path fill];
    [[UIColor lightGrayColor] setStroke];
    path.lineWidth = 1.F;
    [path stroke];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

@end

//
//  FCCardDetailViewController.m
//  iFreeCell
//
//  Created by Miguel Estévez on 10/4/16.
//  Copyright © 2016 Miguel Estévez. All rights reserved.
//

#import "FCCardDetailViewController.h"
#import "FCCard.h"
#import "FCSlot.h"

#define kTextFieldInitTag   1
#define kTextFieldNumber    11

@interface FCCardDetailViewController ()

@property (nonatomic, strong) NSArray <NSString *> *labelsArray;

@end

@implementation FCCardDetailViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.labelsArray = @[
                            @"",
                            @"Name:           ",
                            @"isRed:          ",
                            @"inFreeCell:     ",
                            @"Position:       ",
                            @"zPosition:      ",
                            @"Column:         ",
                            @"ParentCard:     ",
                            @"ChildCard:      ",
                            @"LastChildCard:  ",
                            @"ParentSlotName: ",
                            @"Stacked:        ",
                            @"Physics:        ",
                            @"",
                        ];
    
    [self setupContent];
}

- (void) setupContent
{
    if( self.slot )
    {
        self.card = self.slot.lastCard;
    }
    
    for( NSInteger tag = kTextFieldInitTag; tag <= kTextFieldInitTag+kTextFieldNumber; tag++ )
    {
        UILabel *label = (UILabel *) [self.view viewWithTag:tag];
        switch (tag)
        {
            case 1:
                [self label:label setText:self.card.name];
                break;
            case 2:
                [self label:label setText:self.card.isRed? @"YES": @"NO"];
                break;
            case 3:
                [self label:label setText:self.card.inFreeCell? @"YES": @"NO"];
                break;
            case 4:
                [self label:label setText:[NSString stringWithFormat:@"(%.2f, %.2f)", self.card.position.x, self.card.position.y]];
                break;
            case 5:
                [self label:label setText:[NSString stringWithFormat:@"%.1f", self.showingZPosition]];
                break;
            case 6:
                [self label:label setText:[NSString stringWithFormat:@"%@", @(self.card.column)]];
                break;
            case 7:
                [self label:label setText:self.card.parentCard.name];
                break;
            case 8:
                [self label:label setText:self.card.childCard.name];
                break;
            case 9:
                [self label:label setText:[[self.card lastChild] name]];
                break;
            case 10:
                [self label:label setText:self.card.parentSlot.name];
                break;
            case 11:
                [self label:label setText:self.card.stacked? @"YES": @"NO"];
                break;
            case 12:
                [self label:label setText:self.card.physicsEnabled?@"YES":@"NO"];
                break;
            case 13:
                if(self.slot)
                    [self label:label setText:[self.slot description]];
                else
                    [self label:label setText:[[self.card firstParentSlot] description]];
                break;
            default:
                break;
        }
    }
}

- (void) label:(UILabel *)label setText:(NSString *)text
{
    NSString *string = [NSString stringWithFormat:@"%@%@", self.labelsArray[label.tag], text];
 
    NSDictionary *attributes = @{ NSForegroundColorAttributeName: [UIColor blackColor] };
    
    NSMutableAttributedString *attrSting = [[NSMutableAttributedString alloc] initWithString:string];
    
    [attrSting setAttributes:attributes range:[string rangeOfString:text? text: @"(null)"]];
    
    [label setAttributedText:attrSting];
}

@end

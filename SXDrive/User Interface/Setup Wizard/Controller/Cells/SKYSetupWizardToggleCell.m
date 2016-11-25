//
//  SKYSetupWizardToggleCell.m
//  SXDrive
//
//  Created by Skylable on 4/22/15.
//  Copyright (c) 2015 Skylable. All rights reserved.
//

#import "SKYSetupWizardToggleCell.h"

@implementation SKYSetupWizardToggleCell

#pragma mark - View life

- (void)awakeFromNib {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark - Actions

-(IBAction)toggleValueDidChange:(id)sender {
    [self.delegate cell:self toggleValueDidChange:((UISwitch *)sender).on];
}

@end

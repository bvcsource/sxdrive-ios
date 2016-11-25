//
//  SKYSetupWizardToggleCell.h
//  SXDrive
//
//  Created by Skylable on 4/22/15.
//  Copyright (c) 2015 Skylable. All rights reserved.
//

#import "SKYSetupWizardBaseCell.h"

@interface SKYSetupWizardToggleCell : SKYSetupWizardBaseCell

@property (nonatomic, weak) IBOutlet UISwitch *switchControl;

-(IBAction)toggleValueDidChange:(id)sender;

@end

//
//  SKYSetupWizardInputCell.h
//  SXDrive
//
//  Created by Skylable on 4/22/15.
//  Copyright (c) 2015 Skylable. All rights reserved.
//

#import "SKYSetupWizardBaseCell.h"

@interface SKYSetupWizardInputCell : SKYSetupWizardBaseCell <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *textField;

@end

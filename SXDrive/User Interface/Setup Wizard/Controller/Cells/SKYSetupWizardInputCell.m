//
//  SKYSetupWizardInputCell.m
//  SXDrive
//
//  Created by Skylable on 4/22/15.
//  Copyright (c) 2015 Skylable. All rights reserved.
//

#import "SKYSetupWizardInputCell.h"

@implementation SKYSetupWizardInputCell

#pragma mark - View life

- (void)awakeFromNib {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark - Text fiel delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self.delegate cellDidBeginEditing:self];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [self.delegate cell:self textValueDidChange:text];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}

@end

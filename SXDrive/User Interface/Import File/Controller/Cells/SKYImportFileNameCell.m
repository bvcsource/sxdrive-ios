//
//  SKYImportFileNameCell.m
//  SXDrive
//
//  Created by Skylable on 5/25/15.
//  Copyright (c) 2015 Skylable. All rights reserved.
//

#import "SKYImportFileNameCell.h"

@implementation SKYImportFileNameCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Text field delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self.delegate cellTextFieldDidBeginEditing:self];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self.delegate cellTextFieldDidEndEditing:self];
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

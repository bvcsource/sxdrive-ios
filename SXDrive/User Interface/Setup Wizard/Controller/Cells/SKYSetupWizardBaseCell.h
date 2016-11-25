//
//  SKYSetupWizardBaseCell.h
//  SXDrive
//
//  Created by Skylable on 4/22/15.
//  Copyright (c) 2015 Skylable. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kCellUnknown,
    kCellServerAddress,
    kCellAdvancedSettings,
    kCellSSLEncryption,
    kCellPort,
    kCellIPAddress,
    kCellUsername,
    kCellPassword,
    kCellShowPassword
} SKYSetupWizardCellType;

@class SKYSetupWizardInputCell, SKYSetupWizardToggleCell;

@protocol SKYSetupWizardCellDelegate

- (void)cell:(SKYSetupWizardToggleCell *)cell toggleValueDidChange:(BOOL)on;
- (void)cellDidBeginEditing:(SKYSetupWizardInputCell *)cell;
- (void)cell:(SKYSetupWizardInputCell *)cell textValueDidChange:(NSString *)text;

@end

@interface SKYSetupWizardBaseCell : UITableViewCell

@property (nonatomic, assign) id<SKYSetupWizardCellDelegate> delegate;
@property (nonatomic, assign) SKYSetupWizardCellType cellType;

@property (nonatomic, weak) IBOutlet UILabel *mainTitleLabel;

@end

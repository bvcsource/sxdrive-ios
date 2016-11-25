//
//  SKYImportFileNameCell.h
//  SXDrive
//
//  Created by Skylable on 5/25/15.
//  Copyright (c) 2015 Skylable. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SKYImportFileNameCell;

@protocol SKYImportFileNameCellDelegate

- (void)cellTextFieldDidBeginEditing:(SKYImportFileNameCell *)cell;
- (void)cellTextFieldDidEndEditing:(SKYImportFileNameCell *)cell;
- (void)cell:(SKYImportFileNameCell *)cell textValueDidChange:(NSString *)text;

@end

@interface SKYImportFileNameCell : UITableViewCell <UITextFieldDelegate>

@property (nonatomic, assign) id<SKYImportFileNameCellDelegate> delegate;

@property (nonatomic, weak) IBOutlet UITextField *textField;
@property (nonatomic, weak) IBOutlet UIImageView *fileIconImageView;

@end

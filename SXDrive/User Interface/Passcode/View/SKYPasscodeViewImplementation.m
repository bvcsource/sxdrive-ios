//
//  SKYPasscodeViewImplementation.m
//  SXDrive
//
//  Created by Skylable on 01/11/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYPasscodeViewImplementation.h"

#import "UIColor+SKYColor.h"
#import "UIFont+SKYFont.h"

/**
 * Distance between top edge and digits.
 */
static CGFloat const SKYPasscodeViewDistanceBetweenTopEdgeAndDigits = 134.f;

/**
 * Distance between top edge and info label.
 */
static CGFloat const SKYPasscodeViewDistanceBetweenTopEdgeAndInfoLabel = 74.f;

/**
 * Distance between digits.
 */
static CGFloat const SKYPasscodeViewDistanceBetweenDigits = 25.f;

@interface SKYPasscodeViewImplementation () <UITextFieldDelegate>

/**
 * Info label informing user what to do at this screen.
 */
@property (nonatomic, strong) UILabel *infoLabel;

/**
 * Hidden text field to handle user input.
 */
@property (nonatomic, strong) UITextField *hiddenTextField;

/**
 * Entry typed on the keyboard by user.
 */
@property (nonatomic, strong) NSMutableString *userEntry;

/**
 * Digit 1 placeholder.
 */
@property (nonatomic, strong) UIImageView *digit1;

/**
 * Digit 2 placeholder.
 */
@property (nonatomic, strong) UIImageView *digit2;

/**
 * Digit 3 placeholder.
 */
@property (nonatomic, strong) UIImageView *digit3;

/**
 * Digit 4 placeholder.
 */
@property (nonatomic, strong) UIImageView *digit4;

/**
 * Presents the user input as digit1-4 imageViews.
 */
- (void)presentDigits;

@end

@implementation SKYPasscodeViewImplementation

@synthesize interactionDelegate = _interactionDelegate;

- (void)createSubviews
{
	self.backgroundColor = [UIColor groupTableViewBackgroundColor];
	
	self.infoLabel = [UILabel new];
	self.infoLabel.translatesAutoresizingMaskIntoConstraints = NO;
	self.infoLabel.font = [UIFont fontForPasscodeScreen];
	self.infoLabel.numberOfLines = 0;
	self.infoLabel.textAlignment = NSTextAlignmentCenter;
	[self addSubview:self.infoLabel];
	
	[self addConstraint:[NSLayoutConstraint constraintWithItem:self.infoLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:self.infoLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:SKYPasscodeViewDistanceBetweenTopEdgeAndInfoLabel]];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:self.infoLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1 constant:-20.f * 2]];

	self.hiddenTextField = [UITextField new];
	self.hiddenTextField.hidden = YES;
	self.hiddenTextField.delegate = self;
	self.hiddenTextField.keyboardType = UIKeyboardTypeNumberPad;
	// dummy test so the backspace works from the beginning
	self.hiddenTextField.text = @"A";
	[self addSubview:self.hiddenTextField];
	
	self.digit1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pin-full"]];
	self.digit1.translatesAutoresizingMaskIntoConstraints = NO;
	self.digit1.highlightedImage = [UIImage imageNamed:@"pin"];
	self.digit1.contentMode = UIViewContentModeCenter;
	[self addSubview:self.digit1];
	
	self.digit2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pin-full"]];
	self.digit2.translatesAutoresizingMaskIntoConstraints = NO;
	self.digit2.highlightedImage = [UIImage imageNamed:@"pin"];
	self.digit2.contentMode = UIViewContentModeCenter;
	[self addSubview:self.digit2];
	
	self.digit3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pin-full"]];
	self.digit3.translatesAutoresizingMaskIntoConstraints = NO;
	self.digit3.highlightedImage = [UIImage imageNamed:@"pin"];
	self.digit3.contentMode = UIViewContentModeCenter;
	[self addSubview:self.digit3];
	
	self.digit4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pin-full"]];
	self.digit4.translatesAutoresizingMaskIntoConstraints = NO;
	self.digit4.highlightedImage = [UIImage imageNamed:@"pin"];
	self.digit4.contentMode = UIViewContentModeCenter;
	[self addSubview:self.digit4];
	
	UIView *spacer1 = [UIView new];
	spacer1.translatesAutoresizingMaskIntoConstraints = NO;
	[self addSubview:spacer1];
	UIView *spacer2 = [UIView new];
	spacer2.translatesAutoresizingMaskIntoConstraints = NO;
	[self addSubview:spacer2];
	
	NSDictionary *views = @{@"spacer1": spacer1, @"spacer2": spacer2, @"digit1": self.digit1, @"digit2": self.digit2, @"digit3": self.digit3, @"digit4": self.digit4};

	NSDictionary *metrics = @{@"space": @(SKYPasscodeViewDistanceBetweenDigits)};
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[spacer1(>=0)][digit1]-space-[digit2]-space-[digit3]-space-[digit4][spacer2(==spacer1)]|" options:0 metrics:metrics views:views]];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:self.digit1 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:SKYPasscodeViewDistanceBetweenTopEdgeAndDigits]];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:self.digit2 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:SKYPasscodeViewDistanceBetweenTopEdgeAndDigits]];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:self.digit3 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:SKYPasscodeViewDistanceBetweenTopEdgeAndDigits]];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:self.digit4 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:SKYPasscodeViewDistanceBetweenTopEdgeAndDigits]];
	
	[self presentDigits];
}

- (NSMutableString *)userEntry
{
	if (_userEntry == nil) {
		_userEntry = [NSMutableString string];
	}
	
	return _userEntry;
}

- (void)presentDigits
{
	NSArray *digitViews = @[self.digit1, self.digit2, self.digit3, self.digit4];
	
	for (UIImageView *digitView in digitViews) {
		if (self.userEntry.length > [digitViews indexOfObject:digitView]) {
			digitView.highlighted = NO;
		}
		else {
			digitView.highlighted = YES;
		}
	}
}

- (void)showKeyboard
{
	self.hiddenTextField.text = @"A";
	[self.hiddenTextField becomeFirstResponder];
}

- (void)clearUserInput
{
	[self.userEntry deleteCharactersInRange:NSMakeRange(0, self.userEntry.length)];
	self.hiddenTextField.text = @"A";
	
	[self presentDigits];
}

- (void)showInstructionText:(NSString *)instructionText
{
	self.infoLabel.text = instructionText;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	textField.text = @"a";
	
	if (string.length == 0) {
		if (self.userEntry.length > 0) {
			[self.userEntry deleteCharactersInRange:NSMakeRange(self.userEntry.length - 1, 1)];
		}
	}
	else {
		[self.userEntry appendString:string];
	}
	
	[self presentDigits];
	
	if (self.userEntry.length == 4) {
		[self.interactionDelegate userDidEnterPasscode:self.userEntry];
	}
	
	return NO;
}

@end

//
//  SKYPasscodeView.h
//  SXDrive
//
//  Created by Skylable on 01/11/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYBaseView.h"

/**
 * Delegate for handling view events.
 */
@protocol SKYPasscodeViewInteractionDelegate <NSObject>

/**
 * Called when user entered the 4-digit passcode.
 * @param passcode 4-digit passcode as string.
 */
- (void)userDidEnterPasscode:(NSString *)passcode;

@end

/**
 * Protocol of settings view.
 */
@protocol SKYPasscodeView <SKYBaseView>

/**
 * The delegate for interaction events.
 */
@property (nonatomic, weak) id <SKYPasscodeViewInteractionDelegate> interactionDelegate;

/**
 * Shows the keyboard to enter the passcode.
 */
- (void)showKeyboard;

/**
 * Removes all characters from user input.
 */
- (void)clearUserInput;

/**
 * Displays the given instruction text.
 * @param instructionText Instruction text.
 */
- (void)showInstructionText:(NSString *)instructionText;

@end

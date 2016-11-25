//
//  SKYPasscodeController.m
//  SXDrive
//
//  Created by Skylable on 01/11/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYPasscodeController.h"
#import "SKYConfig.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import <SSKeychain/SSKeychain.h>
#import "SKYInfoKeys.h"

@interface SKYPasscodeController ()

/**
 * Property for accessing the passcode view.
 */
@property (weak, nonatomic, readonly) UIView <SKYPasscodeView> *passcodeView;

/**
 * Property for accessing the passcode behaviour.
 */
@property (weak, nonatomic, readonly) id <SKYPasscodeBehaviour> passcodeBehaviour;

@end

@implementation SKYPasscodeController

- (instancetype)initWithPasscodeView:(UIView<SKYPasscodeView> *)passcodeView passcodeBehaviour:(id<SKYPasscodeBehaviour>)passcodeBehaviour
{
	self = [super initWithView:passcodeView behaviour:passcodeBehaviour];
	
	if (self) {
		self.navigationItem.title = NSLocalizedString(@"Passcode", @"Title of passcode screen.");
	}
	
	return self;
}

- (SKYViewType)viewType
{
	return SKYViewTypePasscode;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self.passcodeView clearUserInput];
}

#pragma mark - SKYPasscodeViewInteractionDelegate

- (void)userDidEnterPasscode:(NSString *)passcode
{
	[self.passcodeBehaviour processPasscode:passcode];
}

#pragma mark - SKYPasscodeBehaviourPresenter

- (void)configureForStage:(SKYPasscodeStage)passcodeStage
{
	NSString *instructionText = nil;
	
	switch (passcodeStage) {
		case SKYPasscodeStageEnter: {
			instructionText = NSLocalizedString(@"Enter your passcode to unlock the application.", @"Asking user to provide the passcode to unlock the application.");
			break;
		}
		case SKYPasscodeStageCreate: {
			instructionText = NSLocalizedString(@"Enter the passcode that will protect your data.", @"Asking user to create the passcode to protect his data.");
			break;
		}
		case SKYPasscodeStageConfirm: {
			instructionText = NSLocalizedString(@"Enter the same passcode one more time.", @"Asking user to repeate the passcode.");
			break;
		}
		case SKYPasscodeStageChange: {
			instructionText = NSLocalizedString(@"Enter your current passcode to change it.", @"Asking user to provide old passcode before creating the new one.");
			break;
		}
		case SKYPasscodeStageDelete: {
			instructionText = NSLocalizedString(@"Enter your current passcode to turn it off.", @"Asking user to provide current passcode before turning passcode off.");
			break;
		}
	}
	
	if (passcodeStage == SKYPasscodeStageEnter) {
		NSString *logoutText = NSLocalizedString(@"Logout", @"Text for logout button on passcode screen if user forgot the passcode.");
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:logoutText style:UIBarButtonItemStylePlain target:self.passcodeBehaviour action:@selector(logoutUser)];
        
        LAContext *context = [[LAContext alloc] init];
        if ([SKYConfig touchIDEnabled] && [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil]) {
            [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                    localizedReason:NSLocalizedString(@"Unlock the application.", @"Asking user to provide the touch ID to unlock the application.")
                              reply:^(BOOL success, NSError *error) {
                                  if (success) {
                                      NSString *currentPasscode = [self.passcodeBehaviour.user currentPasscode];
                                      [(NSObject *)self.passcodeBehaviour performSelectorOnMainThread:@selector(processPasscode:) withObject:currentPasscode waitUntilDone:NO];
                                  } else {
                                      [self.passcodeView performSelectorOnMainThread:@selector(showKeyboard) withObject:nil waitUntilDone:NO];
                                  }
                              }];
        } else {
            [self.passcodeView showKeyboard];
        }
    } else {
        [self.passcodeView showKeyboard];
    }
	
	[self.passcodeView showInstructionText:instructionText];
	[self.passcodeView performSelector:@selector(clearUserInput) withObject:nil afterDelay:0.1];
}

- (void)displayInvalidConfirmPasscodeError
{
	[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Wrong password, try again.", @"Text displayed when the passcode doesn't match its confirmation.")
								message:nil
							   delegate:nil
					  cancelButtonTitle:NSLocalizedString(@"OK", @"Generic OK")
					  otherButtonTitles:nil]
	 show];
	
	[self.passcodeView clearUserInput];
}

- (void)displayInvalidCurrentPasscodeError
{
	[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"The passcode is not correct.", @"Text displayed when the entered passcode is not correct.")
								message:nil
							   delegate:nil
					  cancelButtonTitle:NSLocalizedString(@"OK", @"Generic OK")
					  otherButtonTitles:nil] show];
	
	[self.passcodeView clearUserInput];	
}

#pragma mark - Convenience accessors

- (UIView <SKYPasscodeView> *)passcodeView
{
	return (UIView <SKYPasscodeView> *)self.baseView;
}

- (id <SKYPasscodeBehaviour>)passcodeBehaviour
{
	return (id <SKYPasscodeBehaviour>)self.baseBehaviour;
}

@end

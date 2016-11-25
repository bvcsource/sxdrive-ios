//
//  SKYPasscodeBehaviourImplementation.m
//  SXDrive
//
//  Created by Skylable on 01/11/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYPasscodeBehaviourImplementation.h"

#import "SKYInfoKeys.h"
#import "SKYPasscodeStageEnum.h"
#import "SKYUser.h"

@interface SKYPasscodeBehaviourImplementation ()

/**
 * Keeps the passcode stage.
 */
@property (nonatomic) SKYPasscodeStage passcodeStage;

/**
 * Keeps the passcode from previous screen to confirm it.
 */
@property (nonatomic, copy) NSString *passcodeToConfirm;

@end

@implementation SKYPasscodeBehaviourImplementation

@synthesize user = _user;

- (void)processInfo:(NSDictionary *)info
{
	if (info[SKYInfoKeyForPasscodeStage] == nil) {
		self.passcodeStage = SKYPasscodeStageEnter;
	}
	else {
		self.passcodeStage = [info[SKYInfoKeyForPasscodeStage] integerValue];
	}
	
	[self.presenter configureForStage:self.passcodeStage];
}

- (void)processPasscode:(NSString *)passcode
{
	if (self.passcodeStage == SKYPasscodeStageEnter) {
		if ([self.user isPasscodeCorrect:passcode] == YES) {
			[self.viewNavigator closeViewController:[self.presenter viewControler]];
		}
		else {
			[self.presenter displayInvalidConfirmPasscodeError];
		}
	}
	else if (self.passcodeStage == SKYPasscodeStageCreate) {
		self.passcodeToConfirm = passcode;
		self.passcodeStage = SKYPasscodeStageConfirm;
		
		[self.presenter configureForStage:SKYPasscodeStageConfirm];
	}
	else if (self.passcodeStage == SKYPasscodeStageConfirm) {
		if ([passcode isEqualToString:self.passcodeToConfirm] == YES) {
			[self.user setUserPasscode:passcode];
			
			[self.viewNavigator returnFromViewController:[self.presenter viewControler] toViewWithType:SKYViewTypeSettings];
		}
		else {
			[self.presenter displayInvalidConfirmPasscodeError];
		}
	}
	else if (self.passcodeStage == SKYPasscodeStageChange) {
		if ([self.user isPasscodeCorrect:passcode] == YES) {
			self.passcodeStage = SKYPasscodeStageCreate;
			
			[self.presenter configureForStage:SKYPasscodeStageCreate];
		}
		else {
			[self.presenter displayInvalidCurrentPasscodeError];
		}
	}
	else if (self.passcodeStage == SKYPasscodeStageDelete) {
		if ([self.user isPasscodeCorrect:passcode] == YES) {
			[self.user setUserPasscode:nil];
			
			[self.viewNavigator returnFromViewController:[self.presenter viewControler] toViewWithType:SKYViewTypeSettings];
		}
		else {
			[self.presenter displayInvalidCurrentPasscodeError];
		}
	}
}

- (void)logoutUser
{
	[self.user logoutUser];
	[self.viewNavigator navigateFromViewController:[self.presenter viewControler] toViewWithType:SKYViewTypeLogin];
}

@end

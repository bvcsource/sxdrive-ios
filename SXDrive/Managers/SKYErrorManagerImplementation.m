//
//  SKYErrorManagerImplementation.m
//  SXDrive
//
//  Created by Skylable on 19/11/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYErrorManagerImplementation.h"

#import "SKYConfig.h"

/**
 * Tag for generic unknown error.
 */
static NSInteger const SKYErrorManagerInternalErrorTag = 1;

/**
 * Tag for no internet smart error.
 */
static NSInteger const SKYErrorManagerNoInternetSmartErrorTag = 2;

@interface SKYErrorManagerImplementation () <UIAlertViewDelegate>

/**
 * Keeps alert that is displayed and the queue of other alerts.
 */
@property (nonatomic, strong) NSMutableArray *alerts;

/**
 * Last presentation date of no internet smart error.
 */
@property (nonatomic, strong) NSDate *noInternetSmartErrorLastPresentationDate;

/**
 * Displays alert or adds it to the queue.
 * @param alert Alert to display.
 */
- (void)displayAlert:(UIAlertView *)newAlert;

@end

@implementation SKYErrorManagerImplementation

- (NSMutableArray *)alerts
{
	if (_alerts == nil) {
		_alerts = [NSMutableArray array];
	}
	
	return _alerts;
}

- (void)displayAlert:(UIAlertView *)newAlert
{
	BOOL unique = YES;
	for (UIAlertView *alert in self.alerts) {
		if ([alert.title isEqualToString:newAlert.title] && [alert.message isEqualToString:newAlert.message]) {
			unique = NO;
		}
	}
	
	if (unique == YES) {
		[self.alerts addObject:newAlert];
		
		if (self.alerts.count == 1) {
			[newAlert show];
		}
	}
}

- (void)displayVolumesSyncUnknownError
{
	NSString *localizedTitle = NSLocalizedString(@"Volumes unknown error", @"Title of volumes unknown error.");
	NSString *localizedMessage = NSLocalizedString(@"Could not sync volumes because of unknown error, please try again later or contact tech support.", @"Message of volumes unknown error.");
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:localizedTitle message:localizedMessage delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"Generic OK") otherButtonTitles:nil];
	
	[self displayAlert:alert];
}

- (void)displayNotEnoughDiskSpaceError
{
	NSString *localizedTitle = NSLocalizedString(@"Not enough disk space", @"Not enough disk space error.");
	NSString *localizedMessage = NSLocalizedString(@"There is not enough free disk space to complete this operation.", @"Message of not enough disk space error.");
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:localizedTitle message:localizedMessage delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"Generic OK") otherButtonTitles:nil];
	
	[self displayAlert:alert];
}

- (void)displayNoInternetSmartError
{
	if (
		self.noInternetSmartErrorLastPresentationDate == nil ||
		[[NSDate date] timeIntervalSinceDate:self.noInternetSmartErrorLastPresentationDate] > SKYConfigMinimumTimeIntervalForNoInternetSmartAlert
		) {
		NSString *localizedTitle = NSLocalizedString(@"No internet", @"Title of no internet smart error.");
		NSString *localizedMessage = NSLocalizedString(@"You can still use and access all the cached information. All the changes will be performed and files refreshed once the connection is available.", @"Message of no internet smart error.");
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:localizedTitle message:localizedMessage delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"Generic OK") otherButtonTitles:nil];
		alert.tag = SKYErrorManagerNoInternetSmartErrorTag;
		
		[self displayAlert:alert];
	}
}

- (void)displayNoInternetError
{
	NSString *localizedTitle = NSLocalizedString(@"Unable to connect", @"Title of no internet error.");
	NSString *localizedMessage = NSLocalizedString(@"Please check your network connection.", @"Message of no internet error.");
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:localizedTitle message:localizedMessage delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"Generic OK") otherButtonTitles:nil];
	
	[self displayAlert:alert];
}

- (void)displayInvalidLoginCredentialsError
{
	NSString *localizedTitle = NSLocalizedString(@"Invalid credentials", @"Title of invalid credentials login error.");
	NSString *localizedMessage = NSLocalizedString(@"Please verify the credentials.", @"Message of invalid credentials error.");
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:localizedTitle message:localizedMessage delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"Generic OK") otherButtonTitles:nil];
	
	[self displayAlert:alert];
}

- (void)displayAccessDeniedError
{
	NSString *localizedTitle = NSLocalizedString(@"Access Denied", @"Title of 'Access Denied' error.");
	NSString *localizedMessage = NSLocalizedString(@"No write permission to the remote volume.", @"Message of 'Access Denied' error.");

    if([SKYConfig mediaUploadEnabled]) {
        localizedMessage = [ NSString stringWithFormat:@"%@ Camera roll synchronization will be disabled.", localizedMessage ];
        [SKYConfig setMediaUploadEnabled:NO];
        [SKYConfig setPhotoUploadOnCellularEnabled:NO];
        [SKYConfig setVideoUploadOnCellularEnabled:NO];
        [SKYConfig setMediaUploadDestinationPath:nil];
    }

	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:localizedTitle message:localizedMessage delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"Generic OK") otherButtonTitles:nil];
	
	[self displayAlert:alert];
}

- (void)displayNotFoundError
{
    NSString *localizedTitle = NSLocalizedString(@"Not Found", @"Title of 'Not found' error.");
    NSString *localizedMessage = NSLocalizedString(@"The remote volume doesn't exist.", @"Message of 'Not Found' error.");

    if([SKYConfig mediaUploadEnabled]) {
        localizedMessage = [ NSString stringWithFormat:@"%@ Camera roll synchronization will be disabled.", localizedMessage ];
        [SKYConfig setMediaUploadEnabled:NO];
        [SKYConfig setPhotoUploadOnCellularEnabled:NO];
        [SKYConfig setVideoUploadOnCellularEnabled:NO];
        [SKYConfig setMediaUploadDestinationPath:nil];
    }

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:localizedTitle message:localizedMessage delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"Generic OK") otherButtonTitles:nil];
    
    [self displayAlert:alert];
}

- (void)displayInternalError:(NSString *)errorMessage
{
	NSString *localizedTitle = NSLocalizedString(@"Internal error", @"Title of internal error.");
	NSString *localizedMessage = NSLocalizedString(@"Application encountered an internal error, you can continue to use it, but it's recommended to restart the app.", @"Message of unknown generic error.");
    NSString *displayedMessage = [ NSString stringWithFormat:@"%@ ERROR: %@", localizedMessage, errorMessage ];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:localizedTitle message:displayedMessage delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"Generic OK") otherButtonTitles:NSLocalizedString(@"Close app", @"Close app button for error."), nil];
	alert.tag = SKYErrorManagerInternalErrorTag;
	
	[self displayAlert:alert];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	// other button then cancel
	if (buttonIndex != 0) {
		if (alertView.tag == SKYErrorManagerInternalErrorTag) {
			exit(0);
		}
	}
	
	[self.alerts removeObject:alertView];
	
	if (self.alerts.count > 0) {
		[self.alerts.firstObject show];
	}
}

- (void)willPresentAlertView:(UIAlertView *)alertView
{
	if (alertView.tag == SKYErrorManagerNoInternetSmartErrorTag) {
		self.noInternetSmartErrorLastPresentationDate = [NSDate date];
	}
}

@end

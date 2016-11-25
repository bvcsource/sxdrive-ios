//
//  SKYErrorManager.h
//  SXDrive
//
//  Created by Skylable on 19/11/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

@import Foundation;

/**
 * Protocol of error manager.
 */
@protocol SKYErrorManager <NSObject>

/**
 * Displays volumes sync unknown error.
 */
- (void)displayVolumesSyncUnknownError;

/**
 * Displays not enough disk space.
 */
- (void)displayNotEnoughDiskSpaceError;

/**
 * Displays no internet error with information about possibility of using local cache.
 * This error is not presented if the amount of it's previous presentation doesn't meet configured minimum interval.
 */
- (void)displayNoInternetSmartError;

/**
 * Displays no internet error.
 */
- (void)displayNoInternetError;

/**
 * Displays invalid login credentials error.
 */
- (void)displayInvalidLoginCredentialsError;

/**
 * Displays Access Denied error.
 */
- (void)displayAccessDeniedError;

/**
 * Displays Access Denied error.
 */
- (void)displayNotFoundError;

/**
 * Displays invalid login server error.
 */
- (void)displayInvalidLoginServerError;

/**
 * Displays internal error.
 */
- (void)displayInternalError:(NSString *)errorMessage;

@end

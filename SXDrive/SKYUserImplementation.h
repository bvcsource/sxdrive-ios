//
//  SKYUserImplementation.h
//  SXDrive
//
//  Created by Skylable on 12/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYUser.h"

/**
 * Keychain entry for `SXDrive` service.
 */
static NSString * const SKYUserKeychainSXDriveService = @"SXDrive";

/**
 * Keychain entry for `server` account.
 */
static NSString * const SKYUserKeychainServerAccount = @"server";

/**
 * Keychain entry for `username` account.
 */
static NSString * const SKYUserKeychainUsernameAccount = @"username";


/**
 * Keychain entry for `host` account.
 */
static NSString * const SKYUserKeychainHostAccount = @"host";

/**
 * Keychain entry for `port` account.
 */
static NSString * const SKYUserKeychainPortAccount = @"port";

/**
 * Keychain entry for `ssl` account.
 */
static NSString * const SKYUserKeychainSSLAccount = @"ssl";

/**
 * Keychain entry for `SXWeb` account.
 */
static NSString * const SKYUserKeychainSXWebAccount = @"sxweb";

/**
 * Keychain entry for `SXShare` account.
 */
static NSString * const SKYUserKeychainSXShareAccount = @"sxshare";

/**
 * Implementation of user.
 */
@interface SKYUserImplementation : NSObject <SKYUser>

@end

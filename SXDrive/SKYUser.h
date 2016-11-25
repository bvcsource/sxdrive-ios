//
//  SKYUser.h
//  SXDrive
//
//  Created by Skylable on 12/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

@import Foundation;

/**
 * Enumeration of login results.
 */
typedef NS_ENUM(NSUInteger, SKYUserLoginResult) {
	/**
	 * Server is invalid.
	 */
	SKYUserLoginResultWrongServer,
	
	/**
	 * Credentials are invalid.
	 */
	SKYUserLoginResultWrongCredentials,
	
	/**
	 * Network is gone.
	 */
	SKYUserLoginResultNoNetwork,
	
	/**
	 * Login success.
	 */
	SKYUserLoginResultSuccess
};

/**
 * Login completion block.
 * @param result Result of login operation.
 */
typedef void (^SKYUserLoginCompletionBlock)(SKYUserLoginResult result);

/**
 * Protocol of user.
 */
@protocol SKYUser <NSObject>

/**
 * Key property to check if user is logged in or not.
 * Any other properties should be used only if this property is set to `YES`.
 */
@property (nonatomic, readonly) BOOL isUserLoggedIn;

/**
 * Server URL to use.
 */
@property (readonly) NSURL *server;

/**
 * Nodes.
 */
@property (atomic, strong) NSArray *nodes;

/**
 * Token to use.
 */
@property (atomic, readonly) NSString *token;

/**
 * User ID based on the token or empty string if it cannot be extracted.
 */
@property (nonatomic, readonly) NSString *userID;

/**
 * User key based on the token or empty string if it cannot be extracted
 */
@property (nonatomic, readonly) NSString *userKey;

/**
 * User padding based on the token or empty string if it cannot be extracted
 */
@property (nonatomic, readonly) NSString *userPadding;

/**
 * Domain which might be different from IP address.
 */
@property (nonatomic, readonly) NSString *hostURL;

/**
 * Tries to log in the user based on the URL containing the server details and token.
 * @param url        URL containing connection details.
 * @param completion Completion block.
 */
- (void)loginUserWithURL:(NSURL *)url completion:(SKYUserLoginCompletionBlock)completion;

/**
 * Logs out the user.
 */
- (void)logoutUser;

/**
 * Sets user passcode (or changes it).
 * 
 * @note Pass nil to turn the passcode off.
 * @param passcode Passcode.
 */
- (void)setUserPasscode:(NSString *)passcode;

/**
 * Checks if the passcode matches with the one user set before.
 * @param passcode Passcode to check.
 * @return YES if passcode is correct, NO otherwise.
 */
- (BOOL)isPasscodeCorrect:(NSString *)passcode;

/**
 * Checks if the account is passcode protected.
 * @return YES if the account is passcode protected, NO otherwise.
 */
- (BOOL)isPasscodeProtected;

/**
 * Checks if user has touch ID enabled.
 * @return YES if the user has touch ID enabled, NO otherwise.
 */
- (BOOL)isTouchIDEnabled;

/**
 * Rrturns current passcode.
 * @return current passcode.
 */
- (NSString *)currentPasscode;

/**
 * Creates URL for given node (ip address).
 * @param node Node.
 * @return URL configured for this ndoe.
 */
- (NSURL *)urlForNode:(NSString *)node;

@end

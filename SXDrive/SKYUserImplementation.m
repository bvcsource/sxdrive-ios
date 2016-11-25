//
//  SKYUserImplementation.m
//  SXDrive
//
//  Created by Skylable on 12/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYUserImplementation.h"

#import "NSData+Extras.h"
#import "NSFileManager+Extras.h"
#import "SKYAppInjector.h"
#import "SKYCloud.h"
#import "SKYInfoKeys.h"
#import "SKYPersistence.h"
#import "SKYNotificationNames.h"
#import "SKYConfig.h"

#import <SSKeychain/SSKeychain.h>

/**
 * Keychain entry for `nodes` account.
 */
static NSString * const SKYUserKeychainNodesAccount = @"nodes";

/**
 * Keychain entry for `token` account.
 */
static NSString * const SKYUserKeychainTokenAccount = @"token";

/**
 * Keychain entry for `passcode` account.
 */
static NSString * const SKYUserKeychainPasscodeAccount = @"passcode";

@interface SKYUserImplementation ()

/**
 * Property redeclaration to have write access.
 */
@property (nonatomic) BOOL isUserLoggedIn;

/**
 * Property redeclaration to have write access.
 */
@property (atomic, strong) NSString *token;

/**
 * Domain or IP address.
 */
@property (nonatomic) NSString *mainURLPart;

/**
 * Property redeclaration to have write access.
 */
@property (atomic, strong) NSString *hostURL;

/**
 * Port.
 */
@property (nonatomic) NSInteger port;

/**
 * Use SSL.
 */
@property (nonatomic) BOOL useSSL;

/**
 * Cloud, lazy property.
 */
@property (nonatomic, strong) id <SKYCloud> cloud;

@end

@implementation SKYUserImplementation

@synthesize nodes = _nodes;

- (id)init
{
	self = [super init];

	if (self) {
		if ([[NSUserDefaults standardUserDefaults] boolForKey:SKYUserDefaultsHasEverLoggedIn] == YES) {
			_mainURLPart = [SSKeychain passwordForService:SKYUserKeychainSXDriveService
															account:SKYUserKeychainServerAccount];
            _hostURL = [SSKeychain passwordForService:SKYUserKeychainSXDriveService account:SKYUserKeychainHostAccount];
			_token = [SSKeychain passwordForService:SKYUserKeychainSXDriveService
											account:SKYUserKeychainTokenAccount];
			_port = [SSKeychain passwordForService:SKYUserKeychainSXDriveService account:SKYUserKeychainPortAccount].integerValue;
			_useSSL = [SSKeychain passwordForService:SKYUserKeychainSXDriveService account:SKYUserKeychainSSLAccount].boolValue;
			_nodes = [[SSKeychain passwordForService:SKYUserKeychainSXDriveService account:SKYUserKeychainNodesAccount] componentsSeparatedByString:@","];
			
			if (_mainURLPart != nil && _token != nil) {
				_isUserLoggedIn = YES;
			}
		}
		else {
			[SSKeychain deletePasswordForService:SKYUserKeychainSXDriveService
										 account:SKYUserKeychainTokenAccount];
			[SSKeychain deletePasswordForService:SKYUserKeychainSXDriveService
										 account:SKYUserKeychainServerAccount];
			[SSKeychain deletePasswordForService:SKYUserKeychainSXDriveService
										 account:SKYUserKeychainPortAccount];
			[SSKeychain deletePasswordForService:SKYUserKeychainSXDriveService
										 account:SKYUserKeychainSSLAccount];
            [SSKeychain deletePasswordForService:SKYUserKeychainSXDriveService
                                         account:SKYUserKeychainHostAccount];
			[SSKeychain deletePasswordForService:SKYUserKeychainSXDriveService
										 account:SKYUserKeychainNodesAccount];
			[SSKeychain deletePasswordForService:SKYUserKeychainSXDriveService
										 account:SKYUserKeychainPasscodeAccount];
            [SSKeychain deletePasswordForService:SKYUserKeychainSXDriveService
                                         account:SKYUserKeychainSXWebAccount];
            [SSKeychain deletePasswordForService:SKYUserKeychainSXDriveService
                                         account:SKYUserKeychainSXShareAccount];
        }
	}
	
	return self;
}

- (NSURL *)server
{
	NSString *protocol = self.useSSL ? @"https://" : @"http://";
	NSString *stringServer = [NSString stringWithFormat:@"%@%@:%i", protocol, self.mainURLPart, (int)self.port];
	
	return [NSURL URLWithString:stringServer];
}

- (NSURL *)urlForNode:(NSString *)node
{
	NSString *protocol = self.useSSL ? @"https://" : @"http://";
	NSString *stringServer = [NSString stringWithFormat:@"%@%@:%i", protocol, node, (int)self.port];
	
	return [NSURL URLWithString:stringServer];
}

- (id <SKYCloud>)cloud
{
	if (_cloud == nil) {
		_cloud = [SKYAppInjector injectObjectForProtocol:@protocol(SKYCloud)];
	}
	
	return _cloud;
}

- (void)loginUserWithURL:(NSURL *)url completion:(SKYUserLoginCompletionBlock)completion
{
	NSString *urlString = [url.absoluteString stringByReplacingOccurrencesOfString:@"sx://" withString:@""];
    
    NSArray *components;
    if ([urlString rangeOfString:@";"].location != NSNotFound) {
        urlString = [urlString stringByReplacingOccurrencesOfString:@";" withString:@","];
        components = [urlString componentsSeparatedByString:@","];
    } else {
        urlString = [urlString stringByReplacingOccurrencesOfString:@"?" withString:@"&"];
        components = [urlString componentsSeparatedByString:@"&"];
    }
	
	self.useSSL = YES;
    self.token = nil;
    self.nodes = nil;
	self.mainURLPart = [components firstObject];
    if ([self.mainURLPart hasSuffix:@"/"]) {
        self.mainURLPart = [self.mainURLPart substringToIndex:[self.mainURLPart length] - 1];
    }
    self.hostURL = [NSString stringWithFormat:@"%@", self.mainURLPart];
	self.port = 443;
	for (NSString *component in components) {
		if ([component hasPrefix:@"ssl="] == YES) {
			if ([[component substringFromIndex:4] isEqualToString:@"y"] == NO) {
				self.useSSL = NO;
			}
		}
		else if ([component hasPrefix:@"token="] == YES) {
			self.token = [[component substringFromIndex:6] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		}
		else if ([component hasPrefix:@"ip="] == YES) {
			self.mainURLPart = [component substringFromIndex:3];
		}
		else if ([component hasPrefix:@"port="]) {
			self.port = [component substringFromIndex:5].integerValue;
		}
	}
	
	[self.cloud listNodesWithCompletion:^(SKYCloudResponse *response) {
		if (response.connectionError != nil) {
			if (response.connectionError.code == -1009) {
				completion(SKYUserLoginResultNoNetwork);
			}
			else if (response.connectionError.code == -1003) {
				completion(SKYUserLoginResultWrongServer);
			}
			else {
                if ([SKYConfig logEnabled]) {
                    [[[UIAlertView alloc] initWithTitle:@"Error details" message:[response.connectionError description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                }
				completion(SKYUserLoginResultWrongCredentials);
			}
		}
		else {
			[SSKeychain setPassword:self.token forService:SKYUserKeychainSXDriveService
							account:SKYUserKeychainTokenAccount];
			[SSKeychain setPassword:self.mainURLPart
						 forService:SKYUserKeychainSXDriveService
							account:SKYUserKeychainServerAccount];
			[SSKeychain setPassword:[NSString stringWithFormat:@"%i", (int)self.port]
						 forService:SKYUserKeychainSXDriveService
							account:SKYUserKeychainPortAccount];
			[SSKeychain setPassword:self.useSSL ? @"1" : nil
						 forService:SKYUserKeychainSXDriveService
							account:SKYUserKeychainSSLAccount];
            [SSKeychain setPassword:self.hostURL
                         forService:SKYUserKeychainSXDriveService
                            account:SKYUserKeychainHostAccount];
			
			self.nodes = response.jsonDictionary[SKYCloudFileNodeList];
			
			self.isUserLoggedIn = YES;
			[[NSUserDefaults standardUserDefaults] setBool:YES forKey:SKYUserDefaultsHasEverLoggedIn];
			[[NSUserDefaults standardUserDefaults] synchronize];
			
			completion(SKYUserLoginResultSuccess);
		}
	}];
}

- (NSString *)userID
{
	
	NSString *userID = nil;
	@try {
		NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:self.token options:0];
		NSString *decodedString = [decodedData skyHexString];
		
		userID = [decodedString substringWithRange:NSMakeRange(0, 40)];
	}
	@catch (NSException *exception) {
		userID = @"";
	}
	
	return userID;
}

- (NSString *)userKey
{
	NSString *userKey = nil;
	@try {
		NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:self.token options:0];
		NSString *decodedString = [decodedData skyHexString];

		userKey = [decodedString substringWithRange:NSMakeRange(40, 40)];
	}
	@catch (NSException *exception) {
		userKey = @"";
	}
	
	return userKey;
}

- (NSString *)userPadding
{
	NSString *userPadding = nil;
	@try {
		NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:self.token options:0];
		NSString *decodedString = [decodedData skyHexString];

		userPadding = [decodedString substringWithRange:NSMakeRange(80, 4)];
	}
	@catch (NSException *exception) {
		userPadding = @"";
	}
	
	return userPadding;
}

- (void)logoutUser
{
	[SSKeychain deletePasswordForService:SKYUserKeychainSXDriveService
								 account:SKYUserKeychainTokenAccount];
	[SSKeychain deletePasswordForService:SKYUserKeychainSXDriveService
								 account:SKYUserKeychainServerAccount];
    [SSKeychain deletePasswordForService:SKYUserKeychainSXDriveService
                                 account:SKYUserKeychainHostAccount];
    [SSKeychain deletePasswordForService:SKYUserKeychainSXDriveService
								 account:SKYUserKeychainPortAccount];
	[SSKeychain deletePasswordForService:SKYUserKeychainSXDriveService
								 account:SKYUserKeychainSSLAccount];
    [SSKeychain deletePasswordForService:SKYUserKeychainSXDriveService
								 account:SKYUserKeychainNodesAccount];
	[SSKeychain deletePasswordForService:SKYUserKeychainSXDriveService
								 account:SKYUserKeychainPasscodeAccount];
    [SSKeychain deletePasswordForService:SKYUserKeychainSXDriveService
                                 account:SKYUserKeychainSXWebAccount];
    [SSKeychain deletePasswordForService:SKYUserKeychainSXDriveService
                                 account:SKYUserKeychainSXShareAccount];

    // in case some accounts were not deleted, reset their settings
    NSArray *accounts = [SSKeychain allAccounts];
    NSLog(@"Resetting %lu Keychain accounts", (unsigned long) accounts.count);
    for (int i = 0; i < accounts.count; i++) {
        NSError *error = nil;
        if([SSKeychain setPassword:nil forService:SKYUserKeychainSXDriveService account:[accounts objectAtIndex:i] error:&error] == NO && error) {
            NSLog(@"Failed to reset Keychain account: %@, account: %@", [error description], [accounts objectAtIndex:i]);
        }
    }

	[NSFileManager removeAllCachedAndTemporaryFiles];
	id <SKYPersistence> persistence = [SKYAppInjector injectObjectForProtocol:@protocol(SKYPersistence)];
    [persistence reset];
    [persistence deleteAllEntries];

	// TODO: stop all requests from cloud
	
	self.isUserLoggedIn = NO;
}

- (void)setNodes:(NSArray *)nodes
{
	_nodes = nodes;
	
	[SSKeychain setPassword:[nodes componentsJoinedByString:@","] forService:SKYUserKeychainSXDriveService account:SKYUserKeychainNodesAccount];
}

- (void)setUserPasscode:(NSString *)passcode
{
	if (passcode == nil) {
		[SSKeychain deletePasswordForService:SKYUserKeychainSXDriveService
									 account:SKYUserKeychainPasscodeAccount];
	}
	else {
		[SSKeychain setPassword:passcode forService:SKYUserKeychainSXDriveService
						account:SKYUserKeychainPasscodeAccount];
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:SKYUserPasscodeDidChangeNotification object:self];
}

- (BOOL)isPasscodeCorrect:(NSString *)passcode
{
	BOOL toReturn = NO;
	
	if (self.isPasscodeProtected == YES) {
		NSString *currentPasscode = [SSKeychain passwordForService:SKYUserKeychainSXDriveService
														   account:SKYUserKeychainPasscodeAccount];
		if ([currentPasscode isEqualToString:passcode] == YES) {
			toReturn = YES;
		}
	}
	
	return toReturn;
}

- (BOOL)isPasscodeProtected
{
	BOOL toReturn = NO;
	
	NSString *currentPasscode = [SSKeychain passwordForService:SKYUserKeychainSXDriveService
													   account:SKYUserKeychainPasscodeAccount];
	if (currentPasscode != nil) {
		toReturn = YES;
	}
	
	return toReturn;
}

- (BOOL)isTouchIDEnabled {
    return [SKYConfig touchIDEnabled];
}

- (NSString *)currentPasscode {
    if (self.isPasscodeProtected == YES) {
        return [SSKeychain passwordForService:SKYUserKeychainSXDriveService
                                                           account:SKYUserKeychainPasscodeAccount];
    }
    return nil;
}

@end

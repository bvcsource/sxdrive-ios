//
//  SKYCloudRequest.m
//  SXDrive
//
//  Created by Skylable on 04/12/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYCloudRequest.h"

#import "NSData+Extras.h"
#import "NSString+Extras.h"
#import "SKYInfoKeys.h"
#import "SKYUser.h"
#import "SKYUserImplementation.h"

#import <SSKeychain/SSkeychain.h>

@interface SKYCloudRequest ()

/**
 * Path.
 */
@property (nonatomic, strong) NSString *path;

/**
 * HTTP method.
 */
@property (nonatomic, strong) NSString *method;

/**
 * Body.
 */
@property (nonatomic, strong) NSData *body;

/**
 * User.
 */
@property (nonatomic, strong) id <SKYUser> user;

/**
 * Returns authorization token based on given input parameters.
 * @param verb    Verb, i.g. `GET`.
 * @param path    Path, i.g. `?nodeList`.
 * @param date    Date as NSDate object.
 * @param body    Request body.
 * @param userID  User ID.
 * @param userKey User key.
 * @param padding Padding (user).
 * @return Authorization token.
 */
+ (NSString *)authorizationTokenForVerb:(NSString *)verb path:(NSString *)path date:(NSDate *)date body:(NSData *)body userID:(NSString *)userID userKey:(NSString *)userKey padding:(NSString *)padding;

@end

@implementation SKYCloudRequest

+ (instancetype)requestWithPath:(NSString *)path
						 method:(NSString *)method
						   body:(NSData *)body
						   user:(id <SKYUser>)user
{
	SKYCloudRequest *request = [SKYCloudRequest new];
	
	if ([path hasPrefix:@"/"]) {
		path = [path substringWithRange:NSMakeRange(1, path.length - 1)];
	}
	
	request.path = path;
	request.method = method;
	request.body = body;
	request.user = user;
	
	return request;
}

- (NSURLRequest *)urlRequestWithNode:(NSString *)node
{
	NSURL *hostToUse = nil;
	if (node != nil) {
		hostToUse = [self.user urlForNode:node];
	}
	else {
		hostToUse = [self.user server];
	}
	
    NSURL *url;
    if ([self.path rangeOfString:@"api/share"].location != NSNotFound) {
        NSString *shareService = [SSKeychain passwordForService:SKYUserKeychainSXDriveService
                                                               account:SKYUserKeychainSXShareAccount];
        if(!shareService)
            shareService = [SSKeychain passwordForService:SKYUserKeychainSXDriveService
                                                  account:SKYUserKeychainSXWebAccount];
        if(shareService && [shareService length] > 0) {
            if([shareService characterAtIndex:[shareService length] - 1] == '/')
                shareService = [shareService substringToIndex:[shareService length] - 1];
            url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/share", shareService]];
        } else
            url = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.%@/api/share", self.user.hostURL]];
    } else {
        url = [NSURL URLWithString:self.path relativeToURL:hostToUse];
    }
    
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	request.HTTPMethod = self.method;
	
	NSDate *date = [NSDate date];
	NSString *dateString = [SKYCloudRequest stringInRFC2822GMTFormatFromDate:date];
	[request addValue:dateString forHTTPHeaderField:@"Date"];
	[request setHTTPBody:self.body];
	
	NSString *authorization = [SKYCloudRequest authorizationTokenForVerb:self.method
																	path:self.path
																	date:date
																	body:self.body
																  userID:[self.user userID]
																 userKey:[self.user userKey]
																 padding:[self.user userPadding]];
	[request addValue:authorization forHTTPHeaderField:@"Authorization"];
	[request addValue:self.user.hostURL forHTTPHeaderField:@"SX-Cluster-Name"];
	[request addValue:[NSString stringWithFormat:@"%lu", (unsigned long)self.body.length] forHTTPHeaderField:@"Content-Length"];
	
	return request;
}

- (NSURLRequest *)urlRequest
{
	return [self urlRequestWithNode:nil];
}

+ (NSString *)stringInRFC2822GMTFormatFromDate:(NSDate *)date
{
	static dispatch_once_t onceToken;
	static NSDateFormatter * dateFormatter;
	dispatch_once(&onceToken, ^{
		dateFormatter = [[NSDateFormatter alloc] init];
		NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
		[dateFormatter setLocale:enUSPOSIXLocale];
		
		dateFormatter.dateFormat = @"EEE, dd MMM yyyy HH:mm:ss";
		
		NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
		[dateFormatter setTimeZone:gmt];
	});
	
	NSString *string = [dateFormatter stringFromDate:date];
	
	return [string stringByAppendingString:@" GMT"];
}

+ (NSString *)authorizationTokenForVerb:(NSString *)verb path:(NSString *)path date:(NSDate *)date body:(NSData *)body userID:(NSString *)userID userKey:(NSString *)userKey padding:(NSString *)padding
{
	// example dateString = @"Thu, 10 Jul 2014 13:35:32 GMT";
	NSString *dateString = [self stringInRFC2822GMTFormatFromDate:date];
	NSString *bodySHA1 = [(body ? body : [NSData data]) SHA1];
	NSString *joint = @"\n";
	NSString *toSign = [[@[verb, path, dateString, bodySHA1] componentsJoinedByString:joint] stringByAppendingString:joint];
	NSString *hmac = [toSign HMAC_SHA1WithKeyData:[NSData dataWithHextString:userKey]];
	NSString *toBase = [NSString stringWithFormat:@"%@%@%@", userID, hmac, padding];
	NSString *base64 = [[NSData dataWithHextString:toBase] base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
	
	return [SKYCloudSKYPrefix stringByAppendingString:base64];
}

@end

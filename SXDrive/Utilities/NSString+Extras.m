//
//  NSString+Extras.m
//  SXDrive
//
//  Created by Skylable on 18.09.2014.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "NSString+Extras.h"

#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

@implementation NSString (Extras)

- (NSString *)SHA1
{
	NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
	uint8_t digest[CC_SHA1_DIGEST_LENGTH];
	
	CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
	
	NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
	
	for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
		[output appendFormat:@"%02x", digest[i]];
	}
	
	return output;
}

- (NSString *)HMAC_SHA1WithKey:(NSString *)key
{
	NSAssert([key isKindOfClass:[NSString class]], @"Key must be NSString object.");
	
	const char * cKey  = [key cStringUsingEncoding:NSUTF8StringEncoding];
	const char * cData = [self cStringUsingEncoding:NSASCIIStringEncoding];
	
	unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
	
	CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
	
	NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC
										  length:sizeof(cHMAC)];
	
	const unsigned char * buffer = (const unsigned char *)[HMAC bytes];
	NSMutableString *HMACString = [NSMutableString stringWithCapacity:HMAC.length * 2];
	for (int i = 0; i < HMAC.length; i++) {
		[HMACString appendFormat:@"%02x", buffer[i]];
	}
	
	return HMACString;
}

- (NSString *)HMAC_SHA1WithKeyData:(NSData *)key
{
	const char * cData = [self cStringUsingEncoding:NSASCIIStringEncoding];
	
	unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
	
	CCHmac(kCCHmacAlgSHA1, [key bytes], [key length], cData, strlen(cData), cHMAC);
	
	NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC
										  length:sizeof(cHMAC)];
	
	const unsigned char * buffer = (const unsigned char *)[HMAC bytes];
	NSMutableString *HMACString = [NSMutableString stringWithCapacity:HMAC.length * 2];
	for (int i = 0; i < HMAC.length; i++) {
		[HMACString appendFormat:@"%02x", buffer[i]];
	}
	
	return HMACString;
}

+ (NSString *)randomString
{
	return [self randomStringOfLength:32];
}

+ (NSString *)randomStringOfLength:(NSUInteger)length
{
	NSArray *characters = @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"a", @"b", @"c", @"d", @"e", @"f"];
	
	NSMutableString *randomString = [NSMutableString stringWithCapacity:length];
	
	for (int i = 0; i < length; i++) {
		NSString *character = characters[arc4random_uniform((u_int32_t)characters.count)];
		[randomString appendString:character];
	}
	
	// Returns inmutable copy of mutable string.
	return randomString.copy;
}

+ (NSString *)stringWithName:(NSString *)name withAvoidingNameClashWithExistingNames:(NSArray *)names
{
	NSInteger extraIndex = 0;
	NSString *nameToUse = nil;
	
	while (YES) {
		if (extraIndex != 0) {
			NSString *plainName = [name stringByDeletingPathExtension];
			NSString *extension = [name pathExtension];
			
			nameToUse = [NSString stringWithFormat:@"%@_%i", plainName, (int)extraIndex];
			if (extension.length > 0) {
				nameToUse = [nameToUse stringByAppendingPathExtension:extension];
			}
		}
		else {
			nameToUse = name;
		}
		
		if ([names containsObject:nameToUse] == YES) {
			extraIndex++;
		}
		else {
			break;
		}
	};
	
	return nameToUse;
}

- (NSString *)stringByEscapingPath
{
	NSMutableString *output = [NSMutableString string];
	const unsigned char * source = (const unsigned char *)[self UTF8String];
	int sourceLen = (int)strlen((const char *)source);
	for (int i = 0; i < sourceLen; ++i) {
		const unsigned char thisChar = source[i];
		if (thisChar == ' ') {
			[output appendString:@"%20"];
		}
		else if (thisChar == '/' || thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||  (thisChar >= 'a' && thisChar <= 'z') || (thisChar >= 'A' && thisChar <= 'Z') || (thisChar >= '0' && thisChar <= '9')) {
			[output appendFormat:@"%c", thisChar];
		}
		else {
			[output appendFormat:@"%%%02X", thisChar];
		}
	}
	return output;
}

@end

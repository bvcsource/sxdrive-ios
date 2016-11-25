//
//  NSData+Extras.m
//  SXDrive
//
//  Created by Skylable on 06.10.2014.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "NSData+Extras.h"

#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

@implementation NSData (Extras)

- (NSString *)skyHexString
{
	NSUInteger dataLength = [self length];
	NSMutableString *string = [NSMutableString stringWithCapacity:dataLength * 2];
	const unsigned char * dataBytes = [self bytes];
	
	for (NSInteger idx = 0; idx < dataLength; ++idx) {
		[string appendFormat:@"%02x", dataBytes[idx]];
	}
	
	return [string stringByReplacingOccurrencesOfString:@" " withString:@""];
}

- (NSString *)SHA1
{
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(self.bytes, (CC_LONG)self.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

+ (NSData *)dataWithHextString:(NSString *)hexString
{
	NSUInteger inLength = [hexString length];
	
	unichar *inCharacters = alloca(sizeof(unichar) * inLength);
	[hexString getCharacters:inCharacters range:NSMakeRange(0, inLength)];
	
	UInt8 *outBytes = malloc(sizeof(UInt8) * ((inLength / 2) + 1));
	
	NSInteger i, o = 0;
	UInt8 outByte = 0;
	for (i = 0; i < inLength; i++) {
		UInt8 c = inCharacters[i];
		SInt8 value = -1;
		
		if (c >= '0' && c <= '9') {
			value =      (c - '0');
		}
		else if (c >= 'A' && c <= 'F') {
			value = 10 + (c - 'A');
		}
		else if (c >= 'a' && c <= 'f') {
			value = 10 + (c - 'a');
		}
		
		if (value >= 0) {
			if (i % 2 == 1) {
				outBytes[o++] = (outByte << 4) | value;
				outByte = 0;
			}
			else {
				outByte = value;
			}
		}
		else {
			if (o != 0) {
				break;
			}
		}
	}
	
	return [[NSData alloc] initWithBytesNoCopy:outBytes length:o freeWhenDone:YES];
}

@end

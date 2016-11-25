//
//  NSByteCountFormatter+Extras.m
//  SXDrive
//
//  Created by Skylable on 19/11/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "NSByteCountFormatter+Extras.h"

@implementation NSByteCountFormatter (Extras)

+ (NSString *)skyStringWithByteCount:(long long)byteCount
{
	NSString *toReturn = nil;
	
	if (byteCount == 0) {
		return @"0 B";
	}
	else {
		toReturn = [NSByteCountFormatter stringFromByteCount:byteCount countStyle:NSByteCountFormatterCountStyleFile];
	}
	
	return toReturn;
}

@end

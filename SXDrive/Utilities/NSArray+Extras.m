//
//  NSArray+Extras.m
//  SXDrive
//
//  Created by Skylable on 11/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "NSArray+Extras.h"

@implementation NSArray (Extras)

- (id)randomObject
{
	id objectToReturn = nil;
	
	if (self.count != 0) {
		objectToReturn = self[arc4random_uniform((u_int32_t)self.count)];
	}
	
	return objectToReturn;
}

- (NSArray *)middleObjects
{
	NSUInteger count = self.count;
	NSArray *arrayToReturn = nil;
	
	if (count == 0) {
		arrayToReturn = nil;
	}
	else if (count == 1 || count == 2) {
		arrayToReturn = self.copy;
	}
	else if (count % 2 == 1) {
		arrayToReturn = @[self[count / 2]];
	}
	else {
		arrayToReturn = @[self[count / 2 - 1], self[count / 2]];
	}
	
	return arrayToReturn;
}

@end

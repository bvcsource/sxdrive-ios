//
//  SKYItem.m
//  SXDrive
//
//  Created by Skylable on 17.09.2014.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYItem.h"

@implementation SKYItem

@dynamic path;
@dynamic name;
@dynamic isDirectory;
@dynamic updateDate;
@dynamic isFavourite;
@dynamic fileSize;
@dynamic pendingSync;
@dynamic revision;
@dynamic properties;
@dynamic tmpName;
@dynamic addedThruApp;

- (NSString *)adescription
{
	NSMutableString *string = [NSMutableString stringWithString:@"SKYItem"];
	[string appendFormat:@" name: %@ (%@)", self.name, self.path];
	[string appendFormat:@" isDirectory: %@", self.isDirectory.boolValue ? @"YES" : @"NO"];
	
	return string;
}

@end

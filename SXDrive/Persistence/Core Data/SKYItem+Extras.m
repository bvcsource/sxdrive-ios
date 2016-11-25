//
//  SKYItem+Extras.m
//  SXDrive
//
//  Created by Skylable on 17.09.2014.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYItem+Extras.h"

#import "NSFileManager+Extras.h"
#import "NSString+Extras.h"
#import "SKYInfoKeys.h"

/**
 * Name of the SKYItem entity.
 */
NSString * const SKYItemEntityName = @"Item";

/**
 * Name of SKYItem's `name` attribute.
 */
NSString * const SKYItemNameAttributeName = @"name";

/**
 * Name of SKYItem's `updateDate` attribute.
 */
NSString * const SKYItemUpdateDateAttributeName = @"updateDate";

/**
 * Name of SKYItem's `path` attribute.
 */
NSString * const SKYItemPathAttributeName = @"path";

/**
 * Name of SKYItem's `pendingSync` attribute.
 */
NSString * const SKYItemPendingSyncAttributeName = @"pendingSync";

/**
 * Name of SKYItem's `revision` attribute.
 */
NSString * const SKYItemRevisionAttributeName = @"revision";

/**
 * Name of SKYItem's `isFavourite` attribute.
 */
NSString * const SKYItemIsFavouriteAttributeName = @"isFavourite";

/**
 * Name of SKYItem's `isDirectory` attribute.
 */
NSString * const SKYItemIsDirectoryAttributeName = @"isDirectory";

/**
 * Name of SKYItem's `uploadStatus` transient property.
 */
NSString * const SKYItemAddedThruAppAttributeName = @"addedThruApp";

/**
 * Name of SKYItem's `uploadStatus` transient property.
 */
NSString * const SKYItemUploadStatusTransientProperty = @"uploadStatus";

/**
 * Upload status for in progress uploads.
 */
NSString * const SKYItemUploadInProgressStatus = @"Pending Uploads";

/**
 * Upload status for completed uploads.
 */
NSString * const SKYItemUploadCompletedStatus = @"Completed Upload";

@implementation SKYItem (Extras)

- (NSString *)volumeName
{
	NSString *volumeName = nil;
	
	NSArray *pathComponents = [self.fullPath componentsSeparatedByString:@"/"];
	if (pathComponents.count > 1) {
		volumeName = pathComponents[1];
	}
	
	return volumeName;
}

- (NSString *)fullPath
{
	NSString *path = [self.path stringByAppendingPathComponent:self.name];
	if (self.isDirectory.boolValue == YES) {
		path = [path stringByAppendingString:@"/"];
	}
	
	return path;
}

- (instancetype)sameItemInContext:(NSManagedObjectContext *)context
{
	return (SKYItem *)[context objectWithID:self.objectID];
}

- (NSString *)expectedFileLocation
{
	NSString *path = nil;
	if (self.isFavourite.boolValue == YES) {
		path = [NSFileManager pathToFavouriteFiles];
	}
	else {
		path = [NSFileManager pathToOrdinaryFiles];
	}
	
	path = [path stringByAppendingPathComponent:[self.revision SHA1]];
	path = [path stringByAppendingPathComponent:self.name];
	
	return path;
}

- (NSURL *)expectedFileURL
{
	return [NSURL fileURLWithPath:self.expectedFileLocation];
}

- (NSDictionary *)propertiesDictionary
{
	if (self.properties == nil) {
		return @{};
	}
	else {
		return [NSJSONSerialization JSONObjectWithData:[self.properties dataUsingEncoding:NSUTF8StringEncoding]
											   options:0
												 error:NULL];
	}
}

- (void)setPropertyValue:(id)value name:(NSString *)propertyName
{
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:self.propertiesDictionary];
	[dictionary setObject:value forKey:propertyName];
	
	NSData *propertiesData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:NULL];
	self.properties = [[NSString alloc] initWithData:propertiesData encoding:NSUTF8StringEncoding];
}

- (id)propertyValueForName:(NSString *)propertyName
{
	return [self.propertiesDictionary objectForKey:propertyName];
}

- (BOOL)hasProperty:(NSString *)propertyName
{
	return [self.propertiesDictionary.allKeys containsObject:propertyName] == YES;
}

- (NSString *)uploadStatus {
    return [self.pendingSync isEqualToString:SKYConstantPendingSyncToBeUploaded] ? SKYItemUploadInProgressStatus:SKYItemUploadCompletedStatus;
}

- (BOOL)isUploadCompleted {
    return [self.uploadStatus isEqualToString:SKYItemUploadCompletedStatus];
}

@end

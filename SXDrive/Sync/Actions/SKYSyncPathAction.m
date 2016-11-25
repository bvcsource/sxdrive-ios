//
//  SKYSyncPathAction.m
//  SXDrive
//
//  Created by Skylable on 07.10.2014.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYSyncPathAction.h"

#import "SKYCloud.h"
#import "SKYCloudResponse.h"
#import "SKYInfoKeys.h"
#import "SKYItem+Extras.h"
#import "SKYPersistence.h"

@interface SKYSyncPathAction ()

/**
 * Volume name extracted from path.
 */
@property (nonatomic, strong) NSString *volumePath;

/**
 * Real path with stripped volume.
 */
@property (nonatomic, strong) NSString *path;

@end

@implementation SKYSyncPathAction

+ (instancetype)actionWithItem:(SKYItem *)item
{
	NSAssert(item.isDirectory.boolValue == YES, @"SKYSyncPathAction: Item must be a directory!");

	SKYSyncPathAction *action = [SKYSyncPathAction new];
	action.item = item;
	
	NSArray *pathComponents = [item.fullPath pathComponents];
	NSAssert(pathComponents.count >= 3, @"SKYSyncPathAction: Path should at least be `/volume-name/`");
	action.volumePath = [@"/" stringByAppendingPathComponent:pathComponents[1]];
	action.path = [item.fullPath stringByReplacingOccurrencesOfString:action.volumePath withString:@""];
	
	return action;
}

- (void)syncDirector
{
	[self.item setPropertyValue:@YES name:SKYPropertyNameLoading];
	
	NSString *path = [[self.volumePath stringByAppendingPathComponent:self.path] stringByAppendingString:@"/"];
	[self.cloud listDirectoryAtPath:path recursive:NO completion:^(SKYCloudResponse *response) {
		if (response.success == YES) {
			NSDictionary *fileList = response.jsonDictionary[SKYCloudFileList];
			[self processFiles:fileList];
		}
		else {
            NSLog(@"listDirectoryAtPath(syncPathAction) failed");
			[self processErrorWithResponse:response];
		}
	}];
}

//TODO: apple doc
- (void)processFiles:(NSDictionary *)fileList
{
	//TODO not repeating path...
	NSArray *currentFiles = [self.persistence listingOfDirectoryAtPath:[[self.volumePath stringByAppendingPathComponent:self.path] stringByAppendingString:@"/"]];
	
	NSMutableArray *itemsToDelete = [NSMutableArray array];
	for (SKYItem *currentFile in currentFiles) {
		SKYItem *item = (SKYItem *)[[self.persistence managedObjectContext] existingObjectWithID:[currentFile objectID] error:NULL];
		// TODO: to keys
		if (item != nil && ([currentFile.pendingSync isEqualToString:@""] == YES || currentFile.pendingSync == nil)) {
			[itemsToDelete addObject:item];
		}
	}
	
	[[self.persistence managedObjectContext] performBlock:^{
		for (NSString *fileKey in fileList) {
			NSDictionary *fileDictionary = fileList[fileKey];
			NSString *cleanFileKey = [fileKey substringFromIndex:self.path.length];
			
			if ([cleanFileKey hasSuffix:@"/"]) {
				// syncing folder
				NSString *name = [cleanFileKey substringToIndex:cleanFileKey.length - 1];
				
				SKYItem *item = nil;
				
				for (SKYItem *existingItem in currentFiles) {
					if ([existingItem.name isEqualToString:name] == YES  && ([existingItem.pendingSync isEqualToString:@""] == YES || existingItem.pendingSync == nil)) {
						item = (SKYItem *)[[self.persistence managedObjectContext] existingObjectWithID:[existingItem objectID] error:NULL];
						[itemsToDelete removeObject:item];
						break;
					}
				}
				
				if (item == nil) {
					item = [NSEntityDescription insertNewObjectForEntityForName:SKYItemEntityName
														 inManagedObjectContext:[self.persistence managedObjectContext]];
					item.path = [[self.volumePath stringByAppendingPathComponent:self.path] stringByAppendingString:@"/"];
					item.name = name;
				}
				
				if (item.isDirectory.boolValue == NO) {
					item.isDirectory = @YES; // updating if needed
				}
			}
			else {
				// syncing file
				NSString *name = cleanFileKey;
				
				if ([name isEqualToString:SKYConstantNewDirectoryHiddenFile] == YES) {
					continue;
				}
				
				SKYItem *item = nil;
				
				for (SKYItem *existingItem in currentFiles) {
					if ([existingItem.name isEqualToString:name] == YES  && ([existingItem.pendingSync isEqualToString:@""] == YES || existingItem.pendingSync == nil)) {
						item = (SKYItem *)[[self.persistence managedObjectContext] existingObjectWithID:[existingItem objectID] error:NULL];
						[itemsToDelete removeObject:item];
						break;
					}
				}
				
				if (item == nil) {
					item = [NSEntityDescription insertNewObjectForEntityForName:SKYItemEntityName
														 inManagedObjectContext:[self.persistence managedObjectContext]];
					item.path = [[self.volumePath stringByAppendingPathComponent:self.path] stringByAppendingString:@"/"];
					item.name = name;
				}
				
				if ([item.fileSize isEqualToNumber:fileDictionary[SKYCloudFileSize]] == NO) {
					item.fileSize = fileDictionary[SKYCloudFileSize];
				}
				
				if (item.isDirectory.boolValue == YES) {
					item.isDirectory = @NO;
				}
				
				if ([item.revision isEqualToString:fileDictionary[SKYCloudFileRevision]] == NO) {
					item.revision = fileDictionary[SKYCloudFileRevision];
				}
				
				NSNumber *createdAt = fileDictionary[SKYCloudCreatedAt];
				NSDate *date = [NSDate dateWithTimeIntervalSince1970:createdAt.doubleValue];
				
				if ([item.updateDate isEqualToDate:date] == NO) {
					item.updateDate = date;
				}
			}
		}
		
		// deleting files
		for (SKYItem *item in itemsToDelete) {
			[[self.persistence managedObjectContext] deleteObject:item];
		}
		
		// TODO watch for error
		__block NSError *error = nil;
		
		if ([self.item hasProperty:SKYPropertyNameEverSynced] == NO) {
			[self.item setPropertyValue:@YES name:SKYPropertyNameEverSynced];
		}
		
		[self.item setPropertyValue:@NO name:SKYPropertyNameLoading];
		
		[[self.persistence managedObjectContext] save:&error];
		
		[[self.persistence managedObjectContext] performBlock:^{
			self.completionBlock();
		}];
	}];
}

- (BOOL)isEqual:(id)object
{
	if ([object class] == [self class]) {
		SKYSyncPathAction *otherAction = (SKYSyncPathAction *)object;
		
		if ([self.volumePath isEqualToString:otherAction.volumePath] == YES && [self.path isEqualToString:otherAction.path]) {
			return YES;
		}
	}
	
	return [super isEqual:object];
}

@end

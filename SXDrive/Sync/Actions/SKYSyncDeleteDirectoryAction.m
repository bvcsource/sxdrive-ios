//
//  SKYSyncDeleteDirectoryAction.m
//  SXDrive
//
//  Created by Skylable on 14/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYSyncDeleteDirectoryAction.h"

#import "SKYCloud.h"
#import "SKYCloudResponse.h"
#import "SKYInfoKeys.h"
#import "SKYItem+Extras.h"
#import "SKYPersistence.h"
#import "SKYSyncDeleteFileAction.h"

@interface SKYSyncDeleteDirectoryAction ()

/**
 * Item to delete.
 */
@property (nonatomic, strong) SKYItem *itemToDelete;

/**
 * Array containing paths that will be deleted one by one.
 */
@property (nonatomic, strong) NSMutableArray *pathsToDelete;

/**
 * Deletes first path from pathsToDelete.
 */
- (void)deleteFirstPath;

@end

@implementation SKYSyncDeleteDirectoryAction

+ (instancetype)actionWithItem:(SKYItem *)item
{
	SKYSyncDeleteDirectoryAction *action = [SKYSyncDeleteDirectoryAction new];
	action.itemToDelete = item;
	
	return action;
}

- (void)syncDirector
{
	NSString *path = [[self.itemToDelete.path stringByAppendingPathComponent:self.itemToDelete.name] stringByAppendingString:@"/"];
	
	[self.cloud listDirectoryAtPath:path recursive:YES completion:^(SKYCloudResponse *response) {
		if (response.success == YES) {
			NSDictionary *fileList = response.jsonDictionary[SKYCloudFileList];
			for (NSString *filePath in fileList) {
				NSString *pathToDelete = [self.itemToDelete.volumeName stringByAppendingPathComponent:filePath];
				[self.pathsToDelete addObject:pathToDelete];
			}
			
			if (self.pathsToDelete.count > 0) {
				[self deleteFirstPath];
			}
		}
		else {
            NSLog(@"listDirectoryAtPath(syncDirector) failed");
			[self processErrorWithResponse:response];
		}
	}];	
}

- (void)deleteFirstPath
{
	NSString *path = self.pathsToDelete.firstObject;
	
	SKYSyncAction *action = [SKYSyncDeleteFileAction actionWithPath:path];
	action.completionBlock = ^{
		if (self.pathsToDelete.count > 0) {
			[self.pathsToDelete removeObjectAtIndex:0];
			
			if (self.pathsToDelete.count > 0) {
				[self deleteFirstPath];
			}
		}
		else {
			[self finishAction];
		}
	};
	[action syncDirector];
}

- (void)finishAction {
    NSManagedObjectContext *context = [self.persistence managedObjectContext];
    if (self.itemToDelete) {
        [context deleteObject:[self.itemToDelete sameItemInContext:context]];
    }
	[context save:NULL];
	
	self.completionBlock();
}

- (void)failAction
{
	self.completionBlock();
}

#pragma mark - Lazy getters

- (NSMutableArray *)pathsToDelete
{
	if (_pathsToDelete == nil) {
		_pathsToDelete = [NSMutableArray array];
	}
	
	return _pathsToDelete;
}

@end

//
//  SKYSyncDeleteFileAction.m
//  SXDrive
//
//  Created by Skylable on 05.10.2014.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYSyncDeleteFileAction.h"

#import "SKYCloud.h"
#import "SKYCloudResponse.h"
#import "SKYInfoKeys.h"
#import "SKYItem+Extras.h"
#import "SKYPersistence.h"

@interface SKYSyncDeleteFileAction ()

/**
 * Path to delete.
 */
@property (nonatomic, strong) NSString *pathToDelete;

/**
 * Item to delete.
 */
@property (nonatomic, strong) SKYItem *itemToDelete;

/**
 * Request id received after file has been flushed.
 */
@property (nonatomic, strong) NSString *requestId;

/**
 * Poll time interval received after file has been flushed.
 */
@property (nonatomic) NSTimeInterval pollTimeInterval;

/**
 * Used node.
 */
@property (nonatomic, strong) NSString *node;

@end

@implementation SKYSyncDeleteFileAction

+ (instancetype)actionWithItem:(SKYItem *)item
{
	SKYSyncDeleteFileAction *action = [SKYSyncDeleteFileAction new];
	action.itemToDelete = item;
	
	NSString *path = [item.path stringByAppendingPathComponent:item.name];
	action.pathToDelete = path;
	
	return action;
}

+ (instancetype)actionWithPath:(NSString *)path
{
	SKYSyncDeleteFileAction *action = [SKYSyncDeleteFileAction new];
	action.pathToDelete = path;
	
	return action;
}

- (void)syncDirector
{
	[self.cloud deleteFileWithPath:self.pathToDelete completion:^(SKYCloudResponse *response) {
		if (response.success == YES) {
			self.node = response.node;
			NSNumber *minPollInterval = response.jsonDictionary[SKYCloudMinPollInterval];
			self.pollTimeInterval = minPollInterval.doubleValue / 1000.0;
			self.requestId = response.jsonDictionary[SKYCloudRequestId];
			
			[NSThread sleepForTimeInterval:self.pollTimeInterval];
			[self poll];
		}
		else {
            NSLog(@"deleteFileWithPath failed");
			[self processErrorWithResponse:response];
		}
	}];
}

- (void)poll
{
	[self.cloud pollWithRequestId:self.requestId node:self.node completion:^(SKYCloudResponse *response) {
		if (response.success == YES) {
			NSString *status = response.jsonDictionary[SKYCloudRequestStatus];
			
			if ([status isEqualToString:SKYConstantStatusOK] == YES) {
				[self finishAction];
				self.completionBlock();
			}
			else {
				[NSThread sleepForTimeInterval:self.pollTimeInterval];
				[self poll];
			}
		}
		else {
            NSLog(@"pollWithRequestId failed");
			[self processErrorWithResponse:response];
		}
	}];
}

- (void)processErrorWithResponse:(SKYCloudResponse *)response
{
	if (response.statusCode == 404) {
		// because file is already deleted
		[self finishAction];
	}
	else {
		[super processErrorWithResponse:response];
	}
}

- (void)finishAction
{
	if (self.itemToDelete != nil) {
		NSManagedObjectContext *context = [self.persistence managedObjectContext];
		[context deleteObject:[self.itemToDelete sameItemInContext:context]];
		[context save:NULL];
	}
	
	self.completionBlock();
}

- (void)failAction
{
	self.completionBlock();
}

@end

//
//  SKYSyncCreateDirectoryAction.m
//  SXDrive
//
//  Created by Skylable on 03.10.2014.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYSyncCreateDirectoryAction.h"

#import "NSString+Extras.h"
#import "SKYCloud.h"
#import "SKYCloudResponse.h"
#import "SKYInfoKeys.h"
#import "SKYItem.h"
#import "SKYItem+Extras.h"
#import "SKYPersistence.h"

@interface SKYSyncCreateDirectoryAction ()

/**
 * Contains information for the director if checkForFileNameClash method finished with success.
 */
@property (nonatomic) BOOL checkForFileNameClashDone;

/**
 * Contains information for the director if initializeFileUpload method finished with success.
 */
@property (nonatomic) BOOL initializeFileUploadDone;

/**
 * Contains information for the director if flush method finished with success.
 */
@property (nonatomic) BOOL flushDone;

/**
 * Contains information for the director if poll method finished with success.
 */
@property (nonatomic) BOOL pollDone;

/**
 * Upload token received from cloud after upload has been initialized.
 */
@property (nonatomic, strong) NSString *uploadToken;

/**
 * Request id received after file has been flushed.
 */
@property (nonatomic, strong) NSString *requestId;

/**
 * Poll time interval received after file has been flushed.
 */
@property (nonatomic) NSTimeInterval minPollTimeInterval;

/**
 * Used node.
 */
@property (nonatomic, strong) NSString *node;

/**
 * Checks the cloud if there is already the file with the same name.
 * If yes it keeps incrementing the file (_1, _2, _3) before extension.
 */
- (void)checkForFileNameClash;

/**
 * Initializes upload on the cloud, collects specific information how the upload should be performed.
 */
- (void)initializeFileUpload;

/**
 * Finalizes the upload of file.
 */
- (void)flush;

/**
 * Sends the poll query to validate if server has processed the file.
 */
- (void)poll;

@end

@implementation SKYSyncCreateDirectoryAction

+ (instancetype)actionWithItem:(SKYItem *)item
{
	SKYSyncCreateDirectoryAction *action = [SKYSyncCreateDirectoryAction new];
	action.item = item;
	
	return action;
}

- (void)syncDirector
{
	if (self.cancelled == YES) {
		[self failAction];
	}
	else if (self.checkForFileNameClashDone == NO) {
		[self checkForFileNameClash];
	}
	else if (self.initializeFileUploadDone == NO) {
		[self initializeFileUpload];
	}
	else if (self.flushDone == NO) {
		[self flush];
	}
	else if (self.pollDone == NO) {
		dispatch_queue_t queue = dispatch_get_global_queue(QOS_CLASS_UTILITY, 0);
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.minPollTimeInterval * NSEC_PER_SEC)), queue, ^{
			[self poll];
		});
	}
	else {
		[self finishAction];
	}
}

- (void)checkForFileNameClash
{
	[self.cloud listDirectoryAtPath:self.item.path recursive:NO completion:^(SKYCloudResponse *response) {
		if (response.success == YES) {
			NSDictionary *fileList = response.jsonDictionary[SKYCloudFileList];
			
			NSMutableArray *blockedNames = [NSMutableArray array];
			for (NSString *key in fileList) {
				[blockedNames addObject:[key lastPathComponent]];
			}
			
			NSString *nameWithoutClash = [NSString stringWithName:self.item.name withAvoidingNameClashWithExistingNames:blockedNames];
			if ([nameWithoutClash isEqualToString:self.item.name] == NO) {
				self.item.name = nameWithoutClash;
				[[self.persistence managedObjectContext] save:NULL];
			}
			
			self.checkForFileNameClashDone = YES;
			[self syncDirector];
		}
		else {
            NSLog(@"listDirectoryAtPath failed");
			[self processErrorWithResponse:response];
		}
	}];
}

- (void)initializeFileUpload
{
	NSString *path = [self.item.path stringByAppendingPathComponent:self.item.name];
	path = [path stringByAppendingPathComponent:SKYConstantNewDirectoryHiddenFile];
	
	[self.cloud addFileWithPath:path size:0 blockNames:@[] completion:^(SKYCloudResponse *response) {
		if (response.success == YES) {
			self.node = response.node;
			self.uploadToken = response.jsonDictionary[SKYCloudUploadTokenKey];
			
			self.initializeFileUploadDone = YES;
			[self syncDirector];
		}
		else {
            NSLog(@"addFileWithPath failed");
			[self processErrorWithResponse:response];
		}
	}];
}

- (void)flush
{
	[self.cloud flushAddedFileWithUploadToken:self.uploadToken node:self.node completion:^(SKYCloudResponse *response) {
		if (response.success == YES) {
			NSNumber *minPollInterval = response.jsonDictionary[SKYCloudMinPollInterval];
			self.minPollTimeInterval = minPollInterval.doubleValue / 1000.0;
			self.requestId = response.jsonDictionary[SKYCloudRequestId];
			
			self.flushDone = YES;
			[self syncDirector];
		}
		else {
            NSLog(@"flushAddedFileWithUploadToken failed");
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
				self.pollDone = YES;
			}
			
			[self syncDirector];
		}
		else {
            NSLog(@"pollWithRequestId failed");
			[self processErrorWithResponse:response];
		}
	}];
}

- (void)cancelAction
{
	[super cancelAction];
	
	[[self.persistence managedObjectContext] deleteObject:self.item];
	
	dispatch_sync(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
		[[self.cloud operationManager].operationQueue cancelAllOperations];
	});
	
	[self failAction];
}

- (void)finishAction
{
	self.item.pendingSync = nil;
    self.item.addedThruApp = [NSNumber numberWithBool:YES];
	[[self.persistence managedObjectContext] save:NULL];
	
	self.completionBlock();
}

- (void)failAction
{
	self.completionBlock();
}

@end

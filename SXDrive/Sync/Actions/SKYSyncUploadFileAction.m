//
//  SKYSyncUploadFileAction.m
//  SXDrive
//
//  Created by Skylable on 05.10.2014.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYSyncUploadFileAction.h"

#import "NSArray+Extras.h"
#import "NSData+Extras.h"
#import "NSFileManager+Extras.h"
#import "NSString+Extras.h"
#import "SKYCloud.h"
#import "SKYCloudResponse.h"
#import "SKYInfoKeys.h"
#import "SKYItem+Extras.h"
#import "SKYPersistence.h"
#import "SKYSyncBlock.h"
#import "SKYNotificationNames.h"

@interface SKYSyncUploadFileAction ()

/**
 * Contains information for the director if checkForFileNameClash method finished with success.
 */
@property (nonatomic) BOOL checkForFileNameClashDone;

/**
 * Contains information for the director if checkUploadBlocksSize method finished with success.
 */
@property (nonatomic) BOOL checkUploadBlocksSizeDone;

/**
 * Contains information for the director if generateBlockNames method finished with success.
 */
@property (nonatomic) BOOL generateBlockNamesDone;

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
 * Contains information for the director if getUploadedFileInfo method finished with success.
 */
@property (nonatomic) BOOL getUploadedFileInfoDone;

/**
 * Contains information for the director if moveFileToProperDestination method finished with success.
 */
@property (nonatomic) BOOL moveFileToProperDestinationDone;

/**
 * Max size of block set by checkUploadBlocksSize method.
 */
@property (nonatomic) unsigned long long uploadBlockSize;

/**
 * Cluster ID which acts as salt.
 */
@property (nonatomic, strong) NSString *clusterID;

/**
 * Block names from file pending upload.
 */
@property (nonatomic, strong) NSArray *sourceBlockNames;

/**
 * Helper property used to know the filesize.
 */
@property (nonatomic) unsigned long long fileSize;

/**
 * Temporary path of the file.
 */
@property (nonatomic, strong) NSString *tmpPath;

/**
 * File handle for partial data reads.
 */
@property (nonatomic, strong) NSFileHandle *fileHandle;

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
 * Block destinations, contains sync block objects.
 */
@property (atomic, strong) NSMutableArray *blockDestinations;

/**
 * Number of blocks uploaded.
 */
@property (atomic) NSUInteger numberOfBlockUploaded;

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
 * Asks the cloud what block size should be used to upload the file.
 */
- (void)checkUploadBlocksSize;

/**
 * Generates the block names array.
 */
- (void)generateBlockNames;

/**
 * Initializes upload on the cloud, collects specific information how the upload should be performed.
 */
- (void)initializeFileUpload;

/**
 * Uploads all blocks.
 */
- (void)uploadBlocks;

/**
 * Finalizes the upload of file.
 */
- (void)flush;

/**
 * Sends the poll query to validate if server has processed the file.
 */
- (void)poll;

/**
 * Once the upload sequence is finished it gets the file info from server.
 */
- (void)getUploadedFileInfo;

/**
 * Moves file from the pending uploads directory to the appropriate directory.
 */
- (void)moveFileToProperDestination;

/**
 * Method used to obtain data of block at given index.
 * @param index Index of block.
 * @return Block's data.
 */
- (NSData *)blockDataAtIndex:(NSUInteger)index;

/**
 * Method used to obtain data of block for given name.
 * @param name Name of block.
 * @return Block's data.
 */
- (NSData *)blockDataAtName:(NSString *)name;

/**
 * Method use to obtain name of block at given index.
 * @param index Index of block.
 * @return Block's name.
 */
- (NSString *)blockNameAtIndex:(NSUInteger)index;

@end

@implementation SKYSyncUploadFileAction

+ (instancetype)actionWithItem:(SKYItem *)item
{
	SKYSyncUploadFileAction *action = [SKYSyncUploadFileAction new];
	action.item = item;
	action.tmpPath = [[NSFileManager pathToPendingUploadDirectory] stringByAppendingPathComponent:item.tmpName];
	action.fileSize = [NSFileManager sizeOfFileAtPath:action.tmpPath];
	
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
	else if (self.checkUploadBlocksSizeDone == NO) {
		[self checkUploadBlocksSize];
	}
	else if (self.generateBlockNamesDone == NO) {
		[self generateBlockNames];
	}
	else if (self.initializeFileUploadDone == NO) {
		[self initializeFileUpload];
	}
	else if (self.blockDestinations.count > 0) {
		[self uploadBlocks];
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
	else if (self.getUploadedFileInfoDone == NO) {
		[self getUploadedFileInfo];
	}
	else if (self.moveFileToProperDestinationDone == NO) {
		[self moveFileToProperDestination];
	}
	else {
		[self finishAction];
	}
}

- (NSFileHandle *)fileHandle
{
	if (_fileHandle == nil) {
		_fileHandle = [NSFileHandle fileHandleForReadingAtPath:self.tmpPath];
	}
	
	return _fileHandle;
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
            NSLog(@"listDirectoryAtPath(uploadFileAction) failed");
			[self processErrorWithResponse:response];
		}
	}];
}

- (void)checkUploadBlocksSize
{
	[self.cloud blockSizeForVolume:[self.item volumeName] withFileSize:self.fileSize completion:^(SKYCloudResponse *response) {
		if (response.success == YES) {
			self.uploadBlockSize = [response.jsonDictionary[SKYCloudFileBlockSize] unsignedLongLongValue];
			self.clusterID = response.clusterID;
			self.checkUploadBlocksSizeDone = YES;
			[self syncDirector];
		}
		else {
            NSLog(@"blockSizeForVolume(uploadFileAction) failed");
			[self processErrorWithResponse:response];
		}
	}];
}

- (void)generateBlockNames
{
	__weak typeof(self) weakSelf = self;
	dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
		NSMutableArray *blockNames = [NSMutableArray array];
		NSUInteger numberOfBlocks = (NSUInteger)ceil(self.fileSize / (double)self.uploadBlockSize);
		for (int i = 0; i < numberOfBlocks; i++) {
			[blockNames addObject:[self blockNameAtIndex:i]];
		}
		
		dispatch_sync(dispatch_get_main_queue(), ^{
			weakSelf.sourceBlockNames = blockNames;
			weakSelf.generateBlockNamesDone = YES;
			[weakSelf syncDirector];
		});
	});
}

- (void)initializeFileUpload
{
	NSString *path = [self.item.path stringByAppendingPathComponent:self.item.name];
	
	[self.cloud addFileWithPath:path size:self.fileSize blockNames:self.sourceBlockNames completion:^(SKYCloudResponse *response) {
		if (response.success == YES) {
			self.node = response.node;
			self.uploadToken = response.jsonDictionary[SKYCloudUploadTokenKey];
			
			NSDictionary *uploadData = response.jsonDictionary[SKYCloudUploadData];
			self.blockDestinations = [NSMutableArray arrayWithArray:[SKYSyncBlock syncBlocksWithSerializedDictionary:uploadData]];
			
			self.initializeFileUploadDone = YES;
			[self syncDirector];
		}
		else {
            NSLog(@"addFileWithPath(uploadFileAction) failed");
			[self processErrorWithResponse:response];
		}
	}];
}

- (void)uploadBlocks
{
	NSArray *allBlocks = self.blockDestinations.copy;

	for (SKYSyncBlock *syncBlock in allBlocks) {
		NSString *node = [syncBlock randomNode];
		// TODO check if node is here! can be nil
		[self.cloud uploadBlockToNode:node uploadToken:self.uploadToken data:[self blockDataAtName:syncBlock.blockName] completion:^(SKYCloudResponse *response) {
			
			if (response.success == YES) {
				self.numberOfBlockUploaded++;
				[self.blockDestinations removeObject:syncBlock];
				
				float percent = self.numberOfBlockUploaded / (float)(self.numberOfBlockUploaded + self.blockDestinations.count);
				[self.persistence setUploadProgress:percent forItem:self.item];
				
				if (self.blockDestinations.count == 0) {
					[self syncDirector];
				}
			}
			else {
                NSLog(@"uploadBlockToNode(uploadFileAction) failed");
				[self processErrorWithResponse:response];
			}
			
			// TODO must check if too much errors in the queue
			// TODO else condition which will remove the node from available nodes
			// must also check if randomNode contains node - perhaps they all failed
			
#ifdef DEBUG
			NSLog(@"UPLOAD: %@ remaining upload packets: %i", self.item.name, (int)self.blockDestinations.count);
#endif
		}];
	}
}

- (void)flush
{
	[self.fileHandle closeFile];
	
	[self.cloud flushAddedFileWithUploadToken:self.uploadToken node:self.node completion:^(SKYCloudResponse *response) {
		if (response.success == YES) {
			NSNumber *minPollInterval = response.jsonDictionary[SKYCloudMinPollInterval];
			self.minPollTimeInterval = minPollInterval.doubleValue / 1000.0;
			self.requestId = response.jsonDictionary[SKYCloudRequestId];
			
			self.flushDone = YES;
			[self syncDirector];
		}
		else {
            NSLog(@"flushAddedFileWithUploadToken(uploadFileAction) failed");
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
            NSLog(@"pollWithRequestId(uploadFileAction) failed");
			[self processErrorWithResponse:response];
		}
	}];
}

- (void)getUploadedFileInfo
{
	NSString *path = [self.item.path stringByAppendingPathComponent:self.item.name];
	[self.cloud fileAtPath:path completion:^(SKYCloudResponse *response) {
		if (response.success == YES) {
			self.item.fileSize = response.jsonDictionary[SKYCloudFileSize];
			self.item.revision = response.jsonDictionary[SKYCloudFileRevision];
			NSNumber *createdAt = response.jsonDictionary[SKYCloudCreatedAt];
			self.item.updateDate = [NSDate dateWithTimeIntervalSince1970:createdAt.doubleValue];
			
			self.getUploadedFileInfoDone = YES;
			[self syncDirector];
		}
		else {
            NSLog(@"fileAtPath(uploadFileAction) failed");
			[self processErrorWithResponse:response];
		}
	}];
}

- (void)moveFileToProperDestination
{
	NSError *error = nil;
	
	// TODO watch for erro
	if ([[NSFileManager defaultManager] createDirectoryAtPath:[[self.item expectedFileLocation] stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:&error]) {
		
		if ([[NSFileManager defaultManager] moveItemAtPath:self.tmpPath toPath:[self.item expectedFileLocation] error:&error]) {
			self.moveFileToProperDestinationDone = YES;
			[self syncDirector];
		}
	}
}

- (NSData *)blockDataAtIndex:(NSUInteger)index
{
	unsigned long long pointerPosition = index * self.uploadBlockSize;
	[self.fileHandle seekToFileOffset:pointerPosition];
	
	if (pointerPosition + self.uploadBlockSize > self.fileSize) {
		NSMutableData *mutableBytes = [NSMutableData dataWithData:[self.fileHandle readDataToEndOfFile]];
		
		unsigned long long paddingSize = self.uploadBlockSize - mutableBytes.length;
		[mutableBytes increaseLengthBy:paddingSize];
		return mutableBytes;
	}
	else {
		return [self.fileHandle readDataOfLength:self.uploadBlockSize];
	}
}

- (NSData *)blockDataAtName:(NSString *)name
{
	NSUInteger index = [self.sourceBlockNames indexOfObject:name];
	
	if (index != NSNotFound) {
		return [self blockDataAtIndex:index];
	}
	else {
		return nil;
	}
}

- (NSString *)blockNameAtIndex:(NSUInteger)index
{
	NSData *clusterIDData = [self.clusterID dataUsingEncoding:NSUTF8StringEncoding];
	NSMutableData *data = [NSMutableData dataWithData:clusterIDData];
	[data appendData:[self blockDataAtIndex:index]];
	
	return [data SHA1];
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
    [[NSNotificationCenter defaultCenter] postNotificationName:SKYUploadDidFinishNotification object:self.item];
    
	self.item.pendingSync = nil;
    self.item.addedThruApp = [NSNumber numberWithBool:YES];
	[[self.persistence managedObjectContext] save:NULL];
	
	self.completionBlock();
}

- (void)failAction
{
	[[self.persistence managedObjectContext] deleteObject:self.item];
	[[self.persistence managedObjectContext] save:NULL];

	self.completionBlock();
}

@end

//
//  SKYSyncDownloadFileAction.m
//  SXDrive
//
//  Created by Skylable on 10.10.2014.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYSyncDownloadFileAction.h"

#import "NSArray+Extras.h"
#import "NSString+Extras.h"
#import "NSFileManager+Extras.h"
#import "SKYAppInjector.h"
#import "SKYBigTransfersManager.h"
#import "SKYCloud.h"
#import "SKYCloudResponse.h"
#import "SKYErrorManager.h"
#import "SKYFunctions.h"
#import "SKYInfoKeys.h"
#import "SKYItem+Extras.h"
#import "SKYNotificationNames.h"
#import "SKYPersistence.h"
#import "SKYSyncBlock.h"

#import <JFBCrypt/JFBCrypt.h>
#import <RNCryptor/RNDecryptor.h>

@interface SKYSyncDownloadFileAction ()

/**
 * Contains information for the director if loadFileInfo method finished with success.
 */
@property (nonatomic) BOOL loadFileInfoDone;

/**
 * Contains information for the director if compareRevision method finished with success.
 */
@property (nonatomic) BOOL compareRevisionDone;

/**
 * Contains information for the director if local revision is recent or not.
 */
@property (nonatomic) BOOL shouldDownloadFile;

/**
 * Contains information for the director if prepareTempFile method finished with success.
 */
@property (nonatomic) BOOL prepareTempFileDone;

/**
 * Contains information for the director if mergeChunks method finished with success.
 */
@property (nonatomic) BOOL mergeChunksDone;

/**
 * Contains information for the director if moveFileToProperDestination method finished with success.
 */
@property (nonatomic) BOOL moveFileToProperDestinationDone;

/**
 * Block size obtained from loadFileInfo method.
 */
@property (nonatomic) unsigned long long blockSize;

/**
 * Received size so far, used to track progress.
 */
@property (nonatomic) unsigned long long receivedSize;

/**
 * Blocks destinations (and names) obtained from loadFileInfo method.
 */
@property (atomic, strong) NSMutableArray *remainingBlocks;

/**
 * All blocks.
 */
@property (nonatomic, strong) NSArray *allBlocks;

/**
 * File handle for download stream.
 */
@property (nonatomic, strong) NSFileHandle *fileHandle;

/**
 * Temporary output path.
 */
@property (nonatomic, strong) NSString *tmpPath;

/**
 * Checks if the file exists in the cloud and get basic information of it required for futher operations.
 */
- (void)loadFileInfo;

/**
 * Checks if there is already downloaded file for given revision, if yes it ignores download.
 */
- (void)compareRevision;

/**
 * Prepares temporary file to stream the data to.
 */
- (void)prepareTempFile;

/**
 * Downloads all blocks.
 */
- (void)downloadBlocks;

/**
 * Saves data to file.
 * @param data       Data.
 * @param blockIndex Index of block (to put the data in the correct place).
 */
- (void)saveData:(NSData *)data atBlockIndex:(NSUInteger)blockIndex;

/**
 * Merges all the chunks.
 */
- (void)mergeChunks;

/**
 * Moves file from the tmp directory to the appropriate directory.
 */
- (void)moveFileToProperDestination;

@end

@implementation SKYSyncDownloadFileAction

+ (instancetype)actionWithItem:(SKYItem *)item
{
	SKYSyncDownloadFileAction *action = [SKYSyncDownloadFileAction new];
	action.item = item;
	
	return action;
}

- (void)syncDirector
{
	if (self.cancelled == YES) {
		[self failAction];
	}
	else if (self.loadFileInfoDone == NO) {
		[self loadFileInfo];
	}
	else if (self.compareRevisionDone == NO) {
		[self compareRevision];
	}
	else if (self.shouldDownloadFile == YES && self.prepareTempFileDone == NO) {
		[self prepareTempFile];
	}
	else if (self.shouldDownloadFile == YES && self.remainingBlocks.count > 0) {
		[self downloadBlocks];
	}
	else if (self.shouldDownloadFile == YES && self.mergeChunksDone == NO) {
		[self mergeChunks];
	}
	else if (self.shouldDownloadFile == YES && self.moveFileToProperDestinationDone == NO) {
		[self moveFileToProperDestination];
	}
	else {
		[self finishAction];
	}
}

- (void)loadFileInfo
{
	NSString *path = [self.item.path stringByAppendingPathComponent:self.item.name];
	[self.cloud fileAtPath:path completion:^(SKYCloudResponse *response) {
		if (response.success == YES) {
			self.blockSize = [response.jsonDictionary[SKYCloudFileBlockSize] unsignedLongLongValue];
			self.item.fileSize = response.jsonDictionary[SKYCloudFileSize];
			self.item.revision = response.jsonDictionary[SKYCloudFileRevision];
			NSNumber *createdAt = response.jsonDictionary[SKYCloudCreatedAt];
			self.item.updateDate = [NSDate dateWithTimeIntervalSince1970:createdAt.doubleValue];
			self.allBlocks = [NSMutableArray arrayWithArray:[SKYSyncBlock syncBlocksWithSerializedArray:response.jsonDictionary[SKYCloudFileData]]];
			self.remainingBlocks = [NSMutableArray array];
			
			__weak __typeof(self)weakSelf = self;
			dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
				// checking already downloaded blocks
				NSString *tmpPath = [NSFileManager tmpPath];
				
				NSMutableArray *remainingBlocks = [NSMutableArray array];
				unsigned long long receivedSize = 0;
				for (SKYSyncBlock *block in weakSelf.allBlocks) {
					NSString *path = [tmpPath stringByAppendingPathComponent:block.blockName];
					NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:NULL];
					
					if (attributes == nil) {
						[remainingBlocks addObject:block];
					}
					else {
						receivedSize += [attributes fileSize];
					}
				}
				
				dispatch_sync(dispatch_get_main_queue(), ^{
					weakSelf.remainingBlocks = remainingBlocks;
					weakSelf.receivedSize = receivedSize;
					
					weakSelf.loadFileInfoDone = YES;
					[weakSelf syncDirector];
				});
			});
		}
		else {
            NSLog(@"fileAtPath failed");
			[self processErrorWithResponse:response];
		}
	}];
}

- (void)processErrorWithResponse:(SKYCloudResponse *)response
{
	if (response.statusCode == 404) {
		[[self.persistence managedObjectContext] deleteObject:self.item];
		[[self.persistence managedObjectContext] save:NULL];
		
		[self failAction];
	}
	else {
		[super processErrorWithResponse:response];
	}
}

- (void)compareRevision
{
	if ([[NSFileManager defaultManager] fileExistsAtPath:[self.item expectedFileLocation]]) {
		self.shouldDownloadFile = NO;
		
		// setting modification date, to later easily compare files by the date of usage
		NSDictionary *attributes = @{NSFileModificationDate: [NSDate date]};
		[[NSFileManager defaultManager] setAttributes:attributes ofItemAtPath:[self.item expectedFileLocation] error:NULL];
		
		self.compareRevisionDone = YES;
		[self syncDirector];
	}
	else {
		id <SKYBigTransfersManager> bigTransfersManager = [SKYAppInjector injectObjectForProtocol:@protocol(SKYBigTransfersManager)];
		
		__weak typeof(self) weakSelf = self;
		[bigTransfersManager manageDownloadForFile:self.item completion:^(BOOL download) {
			weakSelf.shouldDownloadFile = download;
			
			weakSelf.compareRevisionDone = YES;
			[weakSelf syncDirector];
		}];
	}
}

- (void)prepareTempFile
{
	self.tmpPath = [[NSFileManager tmpPath] stringByAppendingPathComponent:[NSString randomString]];
	
	BOOL created = [[NSFileManager defaultManager] createFileAtPath:self.tmpPath contents:nil attributes:nil];
	if (created) {
		self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:self.tmpPath];
		
		self.prepareTempFileDone = YES;
		[self syncDirector];
	}
	else {
		// TODO error
	}
}

- (void)saveData:(NSData *)data atBlockIndex:(NSUInteger)blockIndex
{
	@synchronized(self) {
		[self.fileHandle seekToFileOffset:self.blockSize * blockIndex];
		
		unsigned long long fileSize = [self.item.fileSize unsignedLongLongValue];
		
		if (self.blockSize * (blockIndex + 1) > fileSize) {
			NSRange interestingDataRange = NSMakeRange(0, fileSize % self.blockSize);
			data = [data subdataWithRange:interestingDataRange];
		}
		[self.fileHandle writeData:data];
		
		self.receivedSize += data.length;
		
		float percent = self.receivedSize / (float)self.item.fileSize.unsignedLongLongValue;
		
		// setting percent only when it's not 100%, let's keep it for later
		if (fEqual(percent, 1.0) == NO) {
			[self.persistence setDownloadProgress:percent forItem:self.item];
		}
	}
}

- (void)downloadBlocks
{
	NSArray *allBlocks = self.remainingBlocks.copy;
	
	__block int operationsInProgress = 0;

	for (SKYSyncBlock *syncBlock in allBlocks) {
		if (operationsInProgress > 10) {
			break; // will be continued on another run of this method
		}
		else {
			operationsInProgress++;
		}
        NSString *randomNode = [syncBlock randomNode];
		[self.cloud blockFromNode:randomNode withName:syncBlock.blockName size:self.blockSize completion:^(SKYCloudResponse *response) {
			
			if (response.success == YES) {
				NSData *data = response.data;
				
				NSString *chunkPath = [[NSFileManager tmpPath] stringByAppendingPathComponent:syncBlock.blockName];
				[data writeToFile:chunkPath atomically:YES];
				
				self.receivedSize += data.length;
				float percent = self.receivedSize / (float)self.item.fileSize.unsignedLongLongValue;
				
				// setting percent only when it's not 100%, let's keep it for later
				if (fEqual(percent, 1.0) == NO) {
					[self.persistence setDownloadProgress:percent forItem:self.item];
				}
				
				[self.remainingBlocks removeObject:syncBlock];

				operationsInProgress--;
				if (operationsInProgress == 0) {
					[self syncDirector];
				}
                
			}
			else {
                NSLog(@"blockFromNode failed with %@", randomNode);

                [syncBlock markNodeAsUnavailable:randomNode];
				[self processErrorWithResponse:response];
			}
			
			// TODO must check if too much errors in the queue
			// must also check if randomNode contains node - perhaps they all failed
		}];
	}
}

- (void)mergeChunks
{
	unsigned long long mergedData = 0;
	NSString *tmpPath = [NSFileManager tmpPath];
	
	for (SKYSyncBlock *block in self.allBlocks) {
		NSString *chunkPath = [tmpPath stringByAppendingPathComponent:block.blockName];
		NSData *chunk = [NSData dataWithContentsOfFile:chunkPath];
		if (mergedData + chunk.length > self.item.fileSize.unsignedLongLongValue) {
			chunk = [chunk subdataWithRange:NSMakeRange(0, self.item.fileSize.unsignedLongLongValue - mergedData)];
			[self.fileHandle writeData:chunk];
		}
		else {
			[self.fileHandle writeData:chunk];
			mergedData += chunk.length;
		}
	}
	
	for (SKYSyncBlock *block in self.allBlocks) {
		NSString *chunkPath = [tmpPath stringByAppendingPathComponent:block.blockName];
		
		[[NSFileManager defaultManager] removeItemAtPath:chunkPath error:NULL];
	}
	
	self.mergeChunksDone = YES;
	[self syncDirector];
}

- (void)moveFileToProperDestination
{
	[self.fileHandle closeFile];
	
	NSString *destinationPath = [self.item expectedFileLocation];
	NSError *error = nil;
	
	[[NSFileManager defaultManager] createDirectoryAtPath:[destinationPath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:&error];
	
	if (error == nil) {
		if ([[NSFileManager defaultManager] moveItemAtPath:self.tmpPath toPath:destinationPath error:&error]) {
			self.moveFileToProperDestinationDone = YES;
			
			if (error == nil) {
				[self.persistence setDownloadProgress:1.0 forItem:self.item];
				[self syncDirector];
			}
			else {
				[self finishAction];
                [self.errorManager displayInternalError:@"moveItemAtPath failed"];
			}
		}
	}
	else {
		[self finishAction];
        [self.errorManager displayInternalError:@"createDirectoryAtPath failed"];
	}
}

- (void)finishAction
{
	self.completionBlock();
}

- (void)failAction
{
	self.completionBlock();
}

- (void)cancelAction
{
	[super cancelAction];
	
	dispatch_sync(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
		[[self.cloud operationManager].operationQueue cancelAllOperations];
	});
	
	[self failAction];
}

- (BOOL)isEqual:(id)object
{
	if ([object class] == [self class]) {
		SKYSyncDownloadFileAction *otherAction = (SKYSyncDownloadFileAction *)object;
		
		if ([self.item.objectID isEqual:otherAction.item.objectID] == YES) {
			return YES;
		}
	}
	
	return [super isEqual:object];
}

@end

@implementation SKYSyncFavouriteDownloadFileAction

+ (instancetype)actionWithItem:(SKYItem *)item
{
	
	id <SKYBigTransfersManager> bigTransferManager = [SKYAppInjector injectObjectForProtocol:@protocol(SKYBigTransfersManager)];
	
	if ([bigTransferManager canDownloadFavouriteFile:item] == YES) {
		SKYSyncFavouriteDownloadFileAction *action = [SKYSyncFavouriteDownloadFileAction new];
		action.item = item;
	
		return action;
	}
	else {
		return nil;
	}
}

@end

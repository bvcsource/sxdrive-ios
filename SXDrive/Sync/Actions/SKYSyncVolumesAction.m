//
//  SKYSyncVolumesAction.m
//  SXDrive
//
//  Created by Skylable on 06.10.2014.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYSyncVolumesAction.h"

#import "SKYAppInjector.h"
#import "SKYCloud.h"
#import "SKYCloudResponse.h"
#import "SKYErrorManager.h"
#import "SKYInfoKeys.h"
#import "SKYItem+Extras.h"
#import "SKYNodeManager.h"
#import "SKYPersistence.h"
#import "SKYUser.h"
#import <SKYUserImplementation.h>

#import <SSKeychain/SSKeychain.h>

/**
 * Simple data object containing the volume info during sync process.
 */
@interface SKYSyncVolumesActionVolumeInfo : NSObject

/**
 * Name of the volume.
 */
@property (nonatomic, strong) NSString *name;

/**
 * Used size in bytes of the volume.
 */
@property (nonatomic) unsigned long long usedSize;

/**
 * Volume access rights.
 */
@property (nonatomic, strong) NSArray *accessRights;

/**
 * Volume filter value.
 */
@property (nonatomic, strong) NSString *filterActive;

@end

@implementation SKYSyncVolumesActionVolumeInfo

- (NSString *)description
{
	return [NSString stringWithFormat:@"SKYSyncVolumesActionVolumeInfo name: `%@`", self.name];
}

@end

#pragma mark -

@interface SKYSyncVolumesAction ()

/**
 * Contains information for the director if loadNodes method finished with success.
 */
@property (nonatomic) BOOL loadNodesDone;

/**
 * Contains information for the director if loadVolumes method finished with success.
 */
@property (nonatomic) BOOL loadVolumesDone;

/**
 * Contains information for the director if synchronizeVolumes method finished with success.
 */
@property (nonatomic) BOOL synchronizeVolumesDone;

/**
 * Volumes list with SKYSyncVolumesActionVolumeInfo objects.
 */
@property (nonatomic, strong) NSMutableArray *volumesList;

/**
 * Helper array containing volumes that doesn't have access rights loaded yet.
 */
@property (atomic, strong) NSMutableArray *volumesListRemainingAccessRights;

/**
 * Helper array containing volumes that doesn't have nodes loaded yet.
 */
@property (atomic, strong) NSMutableArray *volumesListRemainingNodes;

/**
 * Helper array containing volumes that doesn't have filters checked yet.
 */
@property (atomic, strong) NSMutableArray *volumesListRemainingFilterActive;

/**
 * Loads nodes.
 */
- (void)loadNodes;

/**
 * Loads volumes.
 */
- (void)loadVolumes;

/**
 * Loads volumes access rights.
 */
- (void)loadVolumesAccessRights;

/**
 * Loads volumes nodes.
 */
- (void)loadVolumesNodes;

/**
 * Synchronize volumes with database.
 */
- (void)synchronizeVolumes;

/**
 * Checks if volume is encrypted.
 * Set filter UUID in case of encrypted volumes.
 */
- (void)checkFilterActive;

@end

@implementation SKYSyncVolumesAction

- (void)syncDirector
{
	@try {
		if (self.loadNodesDone == NO) {
			[self loadNodes];
		}
		else if (self.loadVolumesDone == NO) {
			[self loadVolumes];
		}
		else if (self.volumesListRemainingAccessRights.count > 0) {
			[self loadVolumesAccessRights];
		}
		else if (self.volumesListRemainingNodes.count > 0) {
			[self loadVolumesNodes];
		}
        else if (self.volumesListRemainingFilterActive.count > 0) {
            [self checkFilterActive];
        }
		else if (self.synchronizeVolumesDone == NO) {
			[self synchronizeVolumes];
		}
		else {
			[self finishAction];
		}
	}
	@catch (NSException *exception) {
		[self finishAction];
		[self.errorManager displayVolumesSyncUnknownError];
	}
}

- (void)loadNodes
{
	[self.cloud listNodesWithCompletion:^(SKYCloudResponse *response) {
		if (response.success == YES) {
			NSArray *nodeList = response.jsonDictionary[SKYCloudFileNodeList];
			id <SKYUser> user = [SKYAppInjector injectObjectForProtocol:@protocol(SKYUser)];
			[user setNodes:nodeList];
			
			self.loadNodesDone = YES;
			[self syncDirector];
		}
		else {
            NSLog(@"listNodesWithCompletion(SyncVolumesAction) failed");
			[self processErrorWithResponse:response];
		}
	}];
}

- (void)loadVolumes
{
	[self.cloud listVolumesWithCompletion:^(SKYCloudResponse *response) {
		if (response.success == YES) {
			self.volumesList = [NSMutableArray array];
			self.volumesListRemainingAccessRights = [NSMutableArray array];
			self.volumesListRemainingNodes = [NSMutableArray array];
            self.volumesListRemainingFilterActive = [NSMutableArray array];
			
			NSDictionary *volumesList = response.jsonDictionary[SKYCloudVolumeList];
			for (NSString *volumeKey in volumesList) {
				NSDictionary *volumeDictionary = volumesList[volumeKey];
				
				SKYSyncVolumesActionVolumeInfo *volumeInfo = [SKYSyncVolumesActionVolumeInfo new];
				volumeInfo.name = volumeKey;
				volumeInfo.usedSize = [volumeDictionary[SKYCloudUsedSize] unsignedLongLongValue];

				[self.volumesList addObject:volumeInfo];
				[self.volumesListRemainingAccessRights addObject:volumeInfo];
				[self.volumesListRemainingNodes addObject:volumeInfo];
                [self.volumesListRemainingFilterActive addObject:volumeInfo];
			}
			
			self.loadVolumesDone = YES;
			[self syncDirector];
		}
		else {
            NSLog(@"listVolumesWithCompletion(SyncVolumesAction) failed");
			[self processErrorWithResponse:response];
		}
	}];
}

- (void)loadVolumesAccessRights
{
	NSArray *volumes = self.volumesListRemainingAccessRights.copy;
	
	for (SKYSyncVolumesActionVolumeInfo *volumeInfo in volumes) {
		[self.cloud listVolumeAccessRights:volumeInfo.name completion:^(SKYCloudResponse *response) {
			if (response.success == YES) {
				[self.volumesListRemainingAccessRights removeObject:volumeInfo];
				
				NSString *responseString = [[NSString alloc] initWithData:response.data encoding:NSUTF8StringEncoding];
				
				NSString *userName = [responseString componentsSeparatedByString:@"\""][1];
				NSArray *accessRights = [response.jsonResponse objectForKey:userName];
				
				if ([accessRights containsObject:SKYConstantWriteAccessRight] == YES && [accessRights containsObject:SKYConstantReadAccessRight] == NO) {
#warning experimental for https://bugzilla.skylable.com/show_bug.cgi?id=1029
					//[self.volumesList removeObject:volumeInfo];
					//[self.volumesListRemainingNodes removeObject:volumeInfo];
				}
				volumeInfo.accessRights = accessRights;
				
				if (self.volumesListRemainingAccessRights.count == 0) {
					[self syncDirector];
				}
			}
			else {
                NSLog(@"listVolumesAccessRights(SyncVolumesAction) failed");
				[self processErrorWithResponse:response];
			}
		}];
	}
}

- (void)loadVolumesNodes
{
	NSArray *volumes = self.volumesListRemainingNodes.copy;
	
	for (SKYSyncVolumesActionVolumeInfo *volumeInfo in volumes) {
		[self.cloud listVolumeNodes:volumeInfo.name completion:^(SKYCloudResponse *response) {
			if (response.success == YES) {
				[self.volumesListRemainingNodes removeObject:volumeInfo];
				
				NSArray *nodeList = response.jsonDictionary[SKYCloudFileNodeList];
				[SKYNodeManager setNodes:nodeList forVolume:volumeInfo.name];
				
				if (self.volumesListRemainingNodes.count == 0) {
					[self syncDirector];
				}
			}
			else {
                NSLog(@"listVolumeNodes(SyncVolumesAction) failed");
				[self processErrorWithResponse:response];
			}
		}];
	}
}

- (NSString *) stringFromHex:(NSString *) hexString
{
    NSInteger len = [hexString length];
    if(len % 2)
        return nil;

    NSMutableString *str = [NSMutableString string];
    for(NSInteger i = 0; i < len; i += 2) {
        NSString *h = [hexString substringWithRange:NSMakeRange(i, 2)];
        unsigned int v = 0;
        sscanf([h UTF8String], "%x", &v);
        [str appendFormat:@"%c", v];
    }
    return str;
}

- (void)synchronizeVolumes
{
	NSArray *currentVolumes = [self.persistence listingOfDirectoryAtPath:@"/"];
	NSMutableArray *volumesToDelete = [NSMutableArray arrayWithArray:currentVolumes];
	
	// updating or adding new volumes
	for (SKYSyncVolumesActionVolumeInfo *volumeInfo in self.volumesList) {
		
		SKYItem *item = nil;
		
		for (SKYItem *existingItem in currentVolumes) {
			if ([existingItem.name isEqualToString:volumeInfo.name] == YES) {
				item = (SKYItem *)[[self.persistence managedObjectContext] existingObjectWithID:[existingItem objectID] error:NULL];
				[volumesToDelete removeObject:item];
				break;
			}
		}
		
		if (item == nil) {
			item = [NSEntityDescription insertNewObjectForEntityForName:SKYItemEntityName
												 inManagedObjectContext:[self.persistence managedObjectContext]];
		}
		
		item.path = @"/";
		item.name = volumeInfo.name;
		item.isDirectory = @YES;
		item.fileSize = @(volumeInfo.usedSize);
		[item setPropertyValue:volumeInfo.accessRights name:SKYPropertyNameAccessRights];
        if (volumeInfo.filterActive) {
            [item setPropertyValue:volumeInfo.filterActive name:SKYPropertyNameFilterActive];
        }
	}
	
	// deleting old volumes
	//TODO: delete also subpaths for this volume that will just remain inaccessible in the database
	for (SKYItem *volumeToDelete in volumesToDelete) {
		[[self.persistence managedObjectContext] deleteObject:volumeToDelete];
	}
    
    // update sxweb_address/sxshare_address
    [self.cloud getClusterMeta:^(SKYCloudResponse *response) {
        if (response.success == YES) {
            NSDictionary *clusterMeta = response.jsonDictionary[@"clusterMeta"];
            NSString *sxMeta = [clusterMeta valueForKey:@"sxshare_address"];
            if(sxMeta) {
                [ SSKeychain setPassword:[ self stringFromHex:sxMeta ] forService:SKYUserKeychainSXDriveService
                                 account:SKYUserKeychainSXShareAccount];
            }

            sxMeta = [clusterMeta valueForKey:@"sxweb_address"];
            if(sxMeta) {
                [ SSKeychain setPassword:[ self stringFromHex:sxMeta ] forService:SKYUserKeychainSXDriveService
                                 account:SKYUserKeychainSXWebAccount];
            }
        }
        else {
            NSLog(@"getClusterMeta(synchronizeVolumes) failed");
        }
    }];
    
	self.synchronizeVolumesDone = YES;
	[self syncDirector];
}

- (void)checkFilterActive {
    NSArray *volumes = self.volumesListRemainingFilterActive.copy;
    for (SKYSyncVolumesActionVolumeInfo *volumeInfo in volumes) {
        [self.cloud filterActiveForVolume:volumeInfo.name completion:^(SKYCloudResponse *response) {
            if (response.success == YES) {
                [self.volumesListRemainingFilterActive removeObject:volumeInfo];
                
                NSDictionary *volumeMeta = response.jsonDictionary[SKYCloudVolumeVolumeMeta];
                NSString *filterActive = [volumeMeta valueForKey:SKYCloudVolumeFilterActive];
                if (filterActive) {
		    /* hide volumes, which use filters */
		    [self.volumesList removeObject:volumeInfo];

                    volumeInfo.filterActive = filterActive;
                }
                
                if (self.volumesListRemainingFilterActive.count == 0) {
                    [self syncDirector];
                }
            }
            else {
                NSLog(@"filterActiveForVolume(SyncVolumesAction) failed");
                [self processErrorWithResponse:response];
            }
        }];
    }
}

- (void)finishAction
{
	[[self.persistence managedObjectContext] save:NULL];
	self.completionBlock();
}

- (void)failAction
{
	self.completionBlock();
}

- (BOOL)isEqual:(id)object
{
	if ([object class] == [self class]) {
		return YES;
	}
	
	return [super isEqual:object];
}

@end

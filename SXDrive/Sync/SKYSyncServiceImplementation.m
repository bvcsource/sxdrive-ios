//
//  SKYSyncServiceImplementation.m
//  SXDrive
//
//  Created by Skylable on 03.10.2014.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

@import CoreData;

#import "SKYSyncServiceImplementation.h"

#import "SKYAppInjector.h"
#import "SKYConfig.h"
#import "SKYCloud.h"
#import "SKYInfoKeys.h"
#import "SKYItem+Extras.h"
#import "SKYPersistence.h"
#import "SKYSyncCreateDirectoryAction.h"
#import "SKYSyncDeleteDirectoryAction.h"
#import "SKYSyncDeleteFileAction.h"
#import "SKYSyncDownloadFileAction.h"
#import "SKYSyncPathAction.h"
#import "SKYSyncUploadFileAction.h"
#import "SKYSyncVolumesAction.h"

@interface SKYSyncServiceImplementation () <NSFetchedResultsControllerDelegate>

/**
 * Fetched results controller monitoring changes that need to be synced.
 */
@property (nonatomic, strong) NSFetchedResultsController *frc;

/**
 * Array containing active sync operations.
 */
@property (nonatomic, strong) NSMutableArray *activeSyncOperations;

/**
 * Persistence to use.
 */
@property (nonatomic, strong) id <SKYPersistence> persistence;

/**
 * Array with objects that have to be kept in sync.
 */
@property (nonatomic, strong) NSMutableArray *keepInSyncArray;

@property (nonatomic, strong) NSMutableArray *queuedDownloadFileActions;

@property (nonatomic, strong) NSMutableArray *queuedDownloadFavouriteFileActions;

/**
 * Creates sync action for given item.
 * @note It only creates action, doesn't schedule it.
 * @param item Item to sync (upload, download, sync).
 * @return Sync action.
 */
- (SKYSyncAction *)syncActionForItem:(SKYItem *)item;

/**
 * Schedules sync action - adds to the active sync operations and starts it on the proper queue.
 * @param syncAction Sync action to schedule.
 */
- (void)scheduleSyncAction:(SKYSyncAction *)syncAction;

/**
 * Syncs all item that should be kept in sync.
 */
- (void)syncKeptInSync;

/**
 * Syncs favourite items.
 */
- (void)syncFavourites;

@end

@implementation SKYSyncServiceImplementation

- (instancetype)init
{
	self = [super init];

	if (self) {
		NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:SKYItemEntityName];
		
		// Sort descriptor required for fetched results controller's sake.
		NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:SKYItemNameAttributeName
																		 ascending:YES];
		fetchRequest.sortDescriptors = @[sortDescriptor];
		
		fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%K != %@ AND %K != nil", SKYItemPendingSyncAttributeName, @"", SKYItemPendingSyncAttributeName];
		
		
		_frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[self.persistence managedObjectContext] sectionNameKeyPath:nil cacheName:nil];
		_frc.delegate = self;
		[_frc performFetch:NULL];
		
		for (SKYItem *item in _frc.fetchedObjects) {
			[self scheduleSyncAction:[self syncActionForItem:item]];
		}
		
		[NSTimer scheduledTimerWithTimeInterval:SKYConfigRefreshKeptInSyncPathTimeInterval target:self selector:@selector(syncKeptInSync) userInfo:nil repeats:YES];
		
		[self syncFavourites];
		[NSTimer scheduledTimerWithTimeInterval:SKYConfigRefreshFavouritesTimeInterval target:self selector:@selector(syncFavourites) userInfo:nil repeats:YES];
	}
	
	return self;
}

- (id <SKYPersistence>)persistence
{
	if (_persistence == nil) {
		_persistence = [SKYAppInjector injectObjectForProtocol:@protocol(SKYPersistence)];
	}
	
	return _persistence;
}

- (NSMutableArray *)keepInSyncArray
{
	if (_keepInSyncArray == nil) {
		_keepInSyncArray = [NSMutableArray array];
	}
	
	return _keepInSyncArray;
}

- (NSMutableArray *)queuedDownloadFileActions
{
	if (_queuedDownloadFileActions == nil) {
		_queuedDownloadFileActions = [NSMutableArray array];
	}
	
	return _queuedDownloadFileActions;
}

- (NSMutableArray *)queuedDownloadFavouriteFileActions
{
	if (_queuedDownloadFavouriteFileActions == nil) {
		_queuedDownloadFavouriteFileActions = [NSMutableArray array];
	}
	
	return _queuedDownloadFavouriteFileActions;
}

- (void)addItemToKeepInSync:(SKYItem *)item
{
	if (item == nil) {
		item = (id)[NSNull null];
	}
	
	if ([self.keepInSyncArray indexOfObject:item] == NSNotFound) {
		[self.keepInSyncArray addObject:item];
		[self syncItem:item favourites:NO];
	}
}

- (void)removeItemFromKeepInSync:(SKYItem *)item
{
	if (item == nil) {
		item = (id)[NSNull null];
	}
	
	if ([self.keepInSyncArray indexOfObject:item] != NSNotFound) {
		[self.keepInSyncArray removeObject:item];
	}
}

- (void)syncKeptInSync
{
	for (SKYItem *item in self.keepInSyncArray) {
		[self syncItem:item favourites:NO];
	}
}

- (void)syncFavourites
{
	NSArray *favouriteItems = [self.persistence favouriteItems];
	for (SKYItem *item in favouriteItems) {
		[self syncItem:item favourites:YES];
	}
}

- (void)scheduleSyncAction:(SKYSyncAction *)syncAction
{
	if ([self.activeSyncOperations containsObject:syncAction] == NO) {
		
		BOOL putToQueue = NO;
		if ([syncAction isKindOfClass:[SKYSyncDownloadFileAction class]] == YES) {
			for (SKYSyncAction *action in self.activeSyncOperations) {
				if ([action class] == [syncAction class]) {
					putToQueue = YES;
					break;
				}
			}
			
			if (putToQueue == YES) {
				if ([syncAction isKindOfClass:[SKYSyncFavouriteDownloadFileAction class]]) {
					[self.queuedDownloadFavouriteFileActions addObject:syncAction];
				}
				else {
					[self.queuedDownloadFileActions addObject:syncAction];
				}
			}
		}
		
		if (putToQueue == NO) {
			[self.activeSyncOperations addObject:syncAction];
			__weak SKYSyncAction *weakAction = syncAction;
			syncAction.completionBlock = ^{
				[self.activeSyncOperations removeObject:weakAction];
				
				if ([weakAction isKindOfClass:[SKYSyncDownloadFileAction class]]) {
					SKYSyncAction *nextAction = nil;
					if ([weakAction isKindOfClass:[SKYSyncFavouriteDownloadFileAction class]]) {
						if (self.queuedDownloadFavouriteFileActions.count > 0) {
							nextAction = self.queuedDownloadFavouriteFileActions.firstObject;
							[self.queuedDownloadFavouriteFileActions removeObjectAtIndex:0];
						}
					}
					else {
						if (self.queuedDownloadFileActions.count > 0) {
							nextAction = self.queuedDownloadFileActions.firstObject;
							[self.queuedDownloadFileActions removeObjectAtIndex:0];
						}
					}
					
					if (nextAction != nil) {
						[self scheduleSyncAction:nextAction];
					}
				}
			};
			
			[syncAction startAction];
		}
	}
	else {
#ifdef DEBUG
		NSUInteger index = [self.activeSyncOperations indexOfObject:syncAction];
		SKYSyncAction *existingSyncAction = self.activeSyncOperations[index];
		NSLog(@"sync action %@ cancelled because it already exists (%@)", syncAction, existingSyncAction);
#endif
	}
}

- (void)syncItem:(SKYItem *)item favourites:(BOOL)favourites
{
	SKYSyncAction *action = nil;
	
	if ([item isMemberOfClass:[NSNull class]]) {
		action = [SKYSyncVolumesAction new];
	}
	else if (item.isDirectory.boolValue == YES) {
		action = [SKYSyncPathAction actionWithItem:item];
	}
	else {
		if (favourites == YES) {
			action = [SKYSyncFavouriteDownloadFileAction actionWithItem:item];
		}
		else {
			// otherwise it sooner or later will be downloaded
			if (item.isFavourite.boolValue == NO) {
				action = [SKYSyncDownloadFileAction actionWithItem:item];
			}
		}
	}
	
	if (action != nil) {
		[self scheduleSyncAction:action];
	}
}

- (void)stopDownloadingItem:(SKYItem *)item
{
	SKYSyncAction *matchingAction = nil;
	for (SKYSyncAction *syncAction in self.activeSyncOperations) {
		if ([syncAction isMemberOfClass:[SKYSyncDownloadFileAction class]] && [syncAction.item.objectID isEqual:item.objectID] == YES) {
			matchingAction = syncAction;
		}
	}
	
	if (matchingAction != nil) {
		[matchingAction cancelAction];
	}
}

- (void)cancelUpload:(SKYItem *)item
{
	SKYSyncAction *matchingAction = nil;
	for (SKYSyncAction *syncAction in self.activeSyncOperations) {
		if ([syncAction isKindOfClass:[SKYSyncCreateDirectoryAction class]] && [syncAction.item.objectID isEqual:item.objectID] == YES) {
			matchingAction = syncAction;
		}
		else if ([syncAction isKindOfClass:[SKYSyncUploadFileAction class]] && [syncAction.item.objectID isEqual:item.objectID] == YES) {
			matchingAction = syncAction;
		}
	}
	
	if (matchingAction != nil) {
		[matchingAction cancelAction];
	}
}

- (NSMutableArray *)activeSyncOperations
{
	if (_activeSyncOperations == nil) {
		_activeSyncOperations = [NSMutableArray array];
	}
	
	return _activeSyncOperations;
}

- (SKYSyncAction *)syncActionForItem:(SKYItem *)item
{
	SKYSyncAction *action = nil;
	
	if ([item.pendingSync isEqualToString:SKYConstantPendingSyncToBeDeleted] == YES) {
		if (item.isDirectory.boolValue == YES) {
			action = [SKYSyncDeleteDirectoryAction actionWithItem:item];
		}
		else {
			action = [SKYSyncDeleteFileAction actionWithItem:item];
		}
	}
	else if ([item.pendingSync isEqualToString:SKYConstantPendingSyncToBeUploaded] == YES) {
		if (item.isDirectory.boolValue == YES) {
			action = [SKYSyncCreateDirectoryAction actionWithItem:item];
		}
		else {
			action = [SKYSyncUploadFileAction actionWithItem:item];
		}
	}
	
	NSAssert(action != nil, @"No sync action for this item.");
	
	return action;
}

#pragma mark - NSFetchedResultsControllerDelegate methods

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
	if (type == NSFetchedResultsChangeInsert) {
		[self scheduleSyncAction:[self syncActionForItem:anObject]];
	}
}

@end

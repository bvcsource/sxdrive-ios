//
//  SKYPersistenceImplementation.m
//  SXDrive
//
//  Created by Skylable on 17.09.2014.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYPersistenceImplementation.h"

#import "NSString+Extras.h"
#import "NSFileManager+Extras.h"
#import "SKYAppInjector.h"
#import "SKYBigTransfersManager.h"
#import "SKYConfig.h"
#import "SKYErrorManager.h"
#import "SKYInfoKeys.h"
#import "SKYItem+Extras.h"
#import "SKYNotificationNames.h"

/**
 * Name of the Core Data Model filename without extension.
 */
static NSString * const SKYPersistenceImplementationCoreDataModelName = @"CoreDataModel";

@interface SKYPersistenceImplementation ()

/**
 * Managed object context used for UI. This is secondary context.
 */
@property (nonatomic, strong) NSManagedObjectContext *mainThreadContext;

/**
 * Managed object context used for background operations. This is primary context.
 */
@property (nonatomic, strong) NSManagedObjectContext *backgroundThreadContext;

/**
 * Managed Object Model for Core Data.
 */
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;

/**
 * Persistent Store Coordinator for Core Data.
 */
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

/**
 * Store type for persistence, usually NSSQLiteStoreType, but in tests NSInMemoryStoreType.
 */
@property (readonly) NSString *storeType;

/**
 * Error manager.
 */
@property (nonatomic, strong) id <SKYErrorManager> errorManager;

/**
 * Downloads progresses.
 */
@property (nonatomic, strong) NSMutableDictionary *downloadProgresses;

/**
 * Upload progresses.
 */
@property (nonatomic, strong) NSMutableDictionary *uploadProgresses;

@end

@implementation SKYPersistenceImplementation

- (void)contextDidSavePrivateQueueContext:(NSNotification *)notification
{
	@synchronized(self) {
		[self.mainThreadContext performBlock:^{
			[self.mainThreadContext mergeChangesFromContextDidSaveNotification:notification];
		}];
	}
}

- (void)contextDidSaveMainQueueContext:(NSNotification *)notification
{
	@synchronized(self) {
		[self.backgroundThreadContext performBlock:^{
			[self.backgroundThreadContext mergeChangesFromContextDidSaveNotification:notification];
			if ([self.backgroundThreadContext hasChanges] == YES) {
				[self.backgroundThreadContext save:NULL];
			}
		}];
	}
}

- (BOOL)canModifyVolumeWithName:(NSString *)volumeName
{
	BOOL canModify = NO;
	
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:SKYItemEntityName];
	fetchRequest.returnsObjectsAsFaults = NO;
	fetchRequest.fetchLimit = 1;
	fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%K = %@ AND %K = %@", SKYItemPathAttributeName, @"/", SKYItemNameAttributeName, volumeName];
	NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:NULL];
	
	if (result.count == 1) {
		SKYItem *item = result[0];
		NSArray *accessRights = [item propertyValueForName:SKYPropertyNameAccessRights];
		if ([accessRights containsObject:SKYConstantWriteAccessRight] == YES) {
			canModify = YES;
		}
	}
	else {
		NSAssert(NO, @"Checking access rights of volume that doesn't exist.");
	}

	return canModify;
}

- (id <SKYErrorManager>)errorManager
{
	if (_errorManager == nil) {
		_errorManager = [SKYAppInjector injectObjectForProtocol:@protocol(SKYErrorManager)];
	}
	
	return _errorManager;
}

- (void)addDirectoryAtPath:(NSString *)path
{
	//TODO check if path exists, if contains allowed characters if ends with /
	SKYItem *item = [NSEntityDescription insertNewObjectForEntityForName:SKYItemEntityName
												  inManagedObjectContext:self.managedObjectContext];
	
	NSString *name = path.lastPathComponent;
	path = [[path stringByDeletingLastPathComponent] stringByAppendingString:@"/"];
	
	item.name = name;
	item.path = path;
	item.isDirectory = @YES;
	item.pendingSync = SKYConstantPendingSyncToBeUploaded;
	
	NSError *error = nil;
	[self.managedObjectContext save:&error];
	
	if (error != nil) {
        [self.errorManager displayInternalError:@"addDirectoryAtPath failed"];
	}
}

- (BOOL)removeItem:(SKYItem *)item;
{
	item.pendingSync = SKYConstantPendingSyncToBeDeleted;
	
	BOOL result = [self.managedObjectContext save:NULL];
	return result;
}

- (void)addFileAtPath:(NSString *)path content:(id)content
{
	NSString *name = path.lastPathComponent;
	path = [path stringByReplacingOccurrencesOfString:name withString:@""];
	NSString *randomCacheName = [NSString randomString];
	NSURL *destinationURL = [[NSFileManager urlToPendingUploadDirectory] URLByAppendingPathComponent:randomCacheName];

	NSNumber *fileSize = nil;
	
	__block NSError *error = nil;
	
	id <SKYBigTransfersManager> bigTransfersManager = [SKYAppInjector injectObjectForProtocol:@protocol(SKYBigTransfersManager)];
	
	if ([content isKindOfClass:[NSURL class]]) {
		NSURL *contentURL = (NSURL *)content;
		fileSize = [NSNumber numberWithUnsignedLongLong:[NSFileManager sizeOfFileAtURL:contentURL]];
	}
	else {
		NSData *contentData = (NSData *)content;
		fileSize = [NSNumber numberWithUnsignedLongLong:contentData.length];
	}
	
	__weak typeof(self) weakSelf = self;
	[bigTransfersManager manageUploadForFileWithSize:fileSize.unsignedLongLongValue completion:^(BOOL upload) {
		if (upload == YES) {
			if ([content isKindOfClass:[NSURL class]]) {
				NSURL *contentURL = (NSURL *)content;
				[[NSFileManager defaultManager] copyItemAtURL:contentURL toURL:destinationURL error:&error];
                [[NSFileManager defaultManager] removeItemAtURL:contentURL error:nil];
			}
			else {
				NSData *contentData = (NSData *)content;
				[contentData writeToURL:destinationURL options:NSDataWritingAtomic error:&error];
			}
			
			if (error == nil) {
				SKYItem *item = [NSEntityDescription insertNewObjectForEntityForName:SKYItemEntityName inManagedObjectContext:weakSelf.managedObjectContext];
				item.name = name;
				item.path = path;
				item.isDirectory = @NO;
				item.fileSize = fileSize;
				item.pendingSync = SKYConstantPendingSyncToBeUploaded;
				item.tmpName = randomCacheName;
				item.updateDate = [NSDate date];
				
				[weakSelf.managedObjectContext save:&error];
				
				if (error != nil) {
                    [weakSelf.errorManager displayInternalError:@"insertNewObjectForEntityForName(addFileAtPath) failed"];
				}
			}
			else {
				[weakSelf.errorManager displayNotEnoughDiskSpaceError];
			}
		}
	}];
}

- (NSArray *)listingOfDirectoryAtPath:(NSString *)path
{
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:SKYItemEntityName];
	fetchRequest.returnsObjectsAsFaults = NO;
	fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%K = %@", SKYItemPathAttributeName, path];

	NSError *error = nil;
	NSArray *items = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	
	if (error == nil) {
		return items;
	}
	else {
        [self.errorManager displayInternalError:@"listingOfDirectoryAtPath failed"];
		
		return nil;
	}
}

- (NSArray *)favouriteItems
{
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:SKYItemEntityName];
	fetchRequest.returnsObjectsAsFaults = NO;
	fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%K = %@ AND %K = nil", SKYItemIsFavouriteAttributeName, @YES, SKYItemPendingSyncAttributeName];
	NSArray *items = [self.managedObjectContext executeFetchRequest:fetchRequest error:NULL];
	return items;
}

- (NSArray *)preferedSortDescriptors
{
	NSSortDescriptor *nameAscending = [NSSortDescriptor sortDescriptorWithKey:SKYItemNameAttributeName
																ascending:YES
																 selector:@selector(compare:)];
	NSSortDescriptor *nameDescending = [NSSortDescriptor sortDescriptorWithKey:SKYItemNameAttributeName
																	 ascending:NO
																	  selector:@selector(compare:)];
	NSSortDescriptor *dateAscending = [NSSortDescriptor sortDescriptorWithKey:SKYItemUpdateDateAttributeName
																	 ascending:YES
																	  selector:@selector(compare:)];
	NSSortDescriptor *dateDescending = [NSSortDescriptor sortDescriptorWithKey:SKYItemUpdateDateAttributeName
																	 ascending:NO
																	  selector:@selector(compare:)];
	
	SKYConfigSortingType sortingType = [SKYConfig prefferedSortingType];

	NSArray *sortDescriptorsToReturn = nil;
	
	switch (sortingType) {
		case SKYConfigSortingTypeByNameAscending: {
			sortDescriptorsToReturn = @[nameAscending];
			break;
		}
		case SKYConfigSortingTypeByNameDescending: {
			sortDescriptorsToReturn = @[nameDescending];
			break;
		}
		case SKYConfigSortingTypeByModificationDateAscending: {
			sortDescriptorsToReturn = @[dateAscending, nameAscending];
			break;
		}
		case SKYConfigSortingTypeByModificationDateDescending: {
			sortDescriptorsToReturn = @[dateDescending, nameAscending];
			break;
		}
	}
	
	return sortDescriptorsToReturn;
}

- (NSFetchedResultsController *)fetchedResultsControllerForDirectory:(SKYItem *)item includeDirectories:(BOOL)includeDirectories
{
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:SKYItemEntityName];
	fetchRequest.returnsObjectsAsFaults = NO;
	NSPredicate *mainPredicate = [NSPredicate predicateWithFormat:@"%K = %@ AND %K = nil", SKYItemPathAttributeName, item.fullPath, SKYItemPendingSyncAttributeName];
	NSCompoundPredicate *compoundPredicate = nil;
	
	if (includeDirectories == NO) {
		NSPredicate *skipDirectoriesPredicate = [NSPredicate predicateWithFormat:@"%K = %@", SKYItemIsDirectoryAttributeName, @NO];
		compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[mainPredicate, skipDirectoriesPredicate]];
		fetchRequest.predicate = compoundPredicate;
	}
	else {
		fetchRequest.predicate = mainPredicate;
	}
	
	fetchRequest.sortDescriptors = [self preferedSortDescriptors];
	
	NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
																		  managedObjectContext:self.managedObjectContext
																			sectionNameKeyPath:nil
																					 cacheName:nil];
	
	return frc;
}

- (NSFetchedResultsController *)fetchedResultsControllerForPendingChangesInDirectory:(SKYItem *)item
{
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:SKYItemEntityName];
	fetchRequest.returnsObjectsAsFaults = NO;

	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@ AND (%K != %@ AND %K != nil)", SKYItemPathAttributeName, item.fullPath, SKYItemPendingSyncAttributeName, SKYConstantPendingSyncToBeDeleted, SKYItemPendingSyncAttributeName];
	
	fetchRequest.predicate = predicate;
	
	NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:SKYItemNameAttributeName
																	 ascending:YES
																	  selector:@selector(localizedStandardCompare:)];
	fetchRequest.sortDescriptors = @[sortDescriptor];
	
	NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
																		  managedObjectContext:self.managedObjectContext
																			sectionNameKeyPath:nil
																					 cacheName:nil];
	
	return frc;
}

- (NSFetchedResultsController *)fetchedResultsControllerForCompletedChangesIncludePendingItems:(BOOL)includePendingItems {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:SKYItemEntityName];
    fetchRequest.returnsObjectsAsFaults = NO;
    
//    NSDate *date = [SKYConfig applicationLaunchDate];
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:-30 * 24 * 3600];
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"%K > %@ AND %K == nil AND %K = %@", SKYItemUpdateDateAttributeName, date, SKYItemPendingSyncAttributeName, SKYItemAddedThruAppAttributeName, @YES];
    if (includePendingItems) {
        NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"%K != %@ AND %K != nil", SKYItemPendingSyncAttributeName, SKYConstantPendingSyncToBeDeleted, SKYItemPendingSyncAttributeName];
        fetchRequest.predicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[predicate1, predicate2]];
    } else {
        fetchRequest.predicate = predicate1;
    }
    
    NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:SKYItemPendingSyncAttributeName
                                                                      ascending:NO
                                                                       selector:@selector(compare:)];
    NSSortDescriptor *sortDescriptor2 = [NSSortDescriptor sortDescriptorWithKey:SKYItemUpdateDateAttributeName
                                                                      ascending:NO
                                                                       selector:@selector(compare:)];
    NSSortDescriptor *sortDescriptor3 = [NSSortDescriptor sortDescriptorWithKey:SKYItemNameAttributeName
                                                                      ascending:YES
                                                                       selector:@selector(localizedStandardCompare:)];
    fetchRequest.sortDescriptors = @[sortDescriptor1, sortDescriptor2, sortDescriptor3];
    
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                          managedObjectContext:self.managedObjectContext
                                                                            sectionNameKeyPath:SKYItemUploadStatusTransientProperty
                                                                                     cacheName:nil];
    
    return frc;
}

- (NSFetchedResultsController *)fetchedResultsControllerForVolumes
{
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:SKYItemEntityName];
	fetchRequest.returnsObjectsAsFaults = NO;

	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@", SKYItemPathAttributeName, @"/"];
	fetchRequest.predicate = predicate;
	
	NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:SKYItemNameAttributeName
																	 ascending:YES
																	  selector:@selector(localizedStandardCompare:)];
	fetchRequest.sortDescriptors = @[sortDescriptor];
	
	NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
																		  managedObjectContext:self.managedObjectContext
																			sectionNameKeyPath:nil
																					 cacheName:nil];
	
	return frc;
}

- (NSFetchedResultsController *)fetchedResultsControllerForFavourites
{
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:SKYItemEntityName];
	fetchRequest.returnsObjectsAsFaults = NO;

	fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%K = %@ AND (%K != %@ OR %K = nil)", SKYItemIsFavouriteAttributeName, @YES, SKYItemPendingSyncAttributeName, SKYConstantPendingSyncToBeDeleted, SKYItemPendingSyncAttributeName];
	NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:SKYItemNameAttributeName
																	 ascending:YES
																	  selector:@selector(localizedStandardCompare:)];
	fetchRequest.sortDescriptors = @[sortDescriptor];
	
	NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
																		  managedObjectContext:self.managedObjectContext
																			sectionNameKeyPath:nil
																					 cacheName:nil];
	
	return frc;
}

- (NSFetchedResultsController *)fetchedResultsControllerForItem:(SKYItem *)item
{
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:SKYItemEntityName];
	fetchRequest.returnsObjectsAsFaults = NO;
	NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:SKYItemNameAttributeName
																	 ascending:YES];
	
	fetchRequest.predicate = [NSPredicate predicateWithFormat:@"SELF = %@", item.objectID];
	fetchRequest.sortDescriptors = @[sortDescriptor];
	NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
																		  managedObjectContext:self.managedObjectContext
																			sectionNameKeyPath:nil
																					 cacheName:nil];
	
	return frc;
}

- (void)addFavouriteFlagToItem:(SKYItem *)item
{
	NSError *error = nil;

	if ([self isItemDownloaded:item] == YES) {
		NSString *currentPath = [[item expectedFileLocation] stringByDeletingLastPathComponent];
		item.isFavourite = @YES;
		NSString *newPath = [[item expectedFileLocation] stringByDeletingLastPathComponent];
		
		
		[[NSFileManager defaultManager] moveItemAtPath:currentPath
												toPath:newPath
												 error:&error];
		
		if (error == nil) {
			[self.managedObjectContext save:&error];
			
			if (error != nil) {
                [self.errorManager displayInternalError:@"managedObjectContext_1(addFavouriteFlagToItem) failed"];
			}
		}
		else {
            [self.errorManager displayInternalError:@"moveItemAtPath(addFavouriteFlagToItem) failed"];
		}
	}
	else {
		item.isFavourite = @YES;
		
		[self.managedObjectContext save:&error];
		
		if (error != nil) {
            [self.errorManager displayInternalError:@"managedObjectContext_2(addFavouriteFlagToItem) failed"];

		}
	}
}

- (void)removeFavouriteFlagToItem:(SKYItem *)item
{
	NSError *error = nil;
	
	if ([self isItemDownloaded:item] == YES) {
		NSString *currentPath = [[item expectedFileLocation] stringByDeletingLastPathComponent];
		item.isFavourite = @NO;
		NSString *newPath = [[item expectedFileLocation] stringByDeletingLastPathComponent];
		
		
		[[NSFileManager defaultManager] moveItemAtPath:currentPath
												toPath:newPath
												 error:&error];
		
		if (error == nil) {
			[self.managedObjectContext save:&error];
			
			if (error != nil) {
                [self.errorManager displayInternalError:@"managedObjectContext_1(removeFavouriteFlagToItem) failed"];
            }
		}
		else {
            [self.errorManager displayInternalError:@"moveItemAtPath(removeFavouriteFlagToItem) failed"];
		}
	}
	else {
		item.isFavourite = @NO;
		
		[self.managedObjectContext save:&error];
		
		if (error != nil) {
            [self.errorManager displayInternalError:@"managedObjectContext_2(removeFavouriteFlagToItem) failed"];

        }
	}
}

- (BOOL)isItemDownloaded:(SKYItem *)item
{
	return [[NSFileManager defaultManager] fileExistsAtPath:item.expectedFileLocation isDirectory:NULL];
}

#pragma mark - Core Data lazy getters

- (NSManagedObjectContext *)managedObjectContext
{
	if ([NSThread isMainThread] == YES) {
		return self.mainThreadContext;
	}
	else {
		return self.backgroundThreadContext;
	}
}

- (NSManagedObjectContext *)mainThreadContext
{
	if (_mainThreadContext == nil) {
		_mainThreadContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
		[_mainThreadContext setParentContext:self.backgroundThreadContext];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(contextDidSaveMainQueueContext:)
													 name:NSManagedObjectContextDidSaveNotification
												   object:_mainThreadContext];
	}
	
	return _mainThreadContext;
}

- (NSManagedObjectContext *)backgroundThreadContext
{
	if (_backgroundThreadContext == nil) {
		_backgroundThreadContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
		
		NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
		NSAssert(coordinator != nil, @"Coordinator should not be nil");
		[_backgroundThreadContext setPersistentStoreCoordinator:coordinator];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(contextDidSavePrivateQueueContext:)
													 name:NSManagedObjectContextDidSaveNotification
												   object:self.backgroundThreadContext];
	}
	
	return _backgroundThreadContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
	if (_managedObjectModel == nil) {
		NSURL *modelURL = [[NSBundle mainBundle] URLForResource:SKYPersistenceImplementationCoreDataModelName withExtension:@"momd"];
		NSAssert(modelURL != nil, @"Cannot find core data model file.");
		
		_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
	}
	
	return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
	if (_persistentStoreCoordinator == nil) {
		_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];

		NSURL *storeURL = [NSURL fileURLWithPath:[NSFileManager databasePath]];
		NSError *error = nil;
		
#ifdef DEBUG
		NSLog(@"Persistent Store Location: %@", storeURL.path);
#endif
		if ([_persistentStoreCoordinator addPersistentStoreWithType:self.storeType configuration:nil URL:storeURL options:@{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES} error:&error] == NO) {
			NSAssert(NO, @"Cannot create persistant store.");
		}
	}
	
	return _persistentStoreCoordinator;
}

- (NSString *)storeType
{
	return NSSQLiteStoreType;
}

- (NSMutableDictionary *)downloadProgresses
{
	if (_downloadProgresses == nil) {
		_downloadProgresses = [NSMutableDictionary dictionary];
	}
	
	return _downloadProgresses;
}

- (void)setDownloadProgress:(float)progress forItem:(SKYItem *)item
{
	[self.downloadProgresses setObject:@(progress) forKey:item.objectID];
	[[NSNotificationCenter defaultCenter] postNotificationName:SKYDownloadProgressDidChangeNotification
														object:item
													  userInfo:@{SKYInfoKeyForDownloadProgress: @(progress)}
	 ];
}

- (float)downloadProgressForItem:(SKYItem *)item
{
	if ([self isItemDownloaded:item]) {
		return 1.f;
	}
	else {
		if ([self.downloadProgresses objectForKey:item.objectID] == nil) {
			return [[self.downloadProgresses objectForKey:item.objectID] floatValue];
		}
		else {
			return 0.f;
		}
	}
}

- (NSMutableDictionary *)uploadProgresses
{
	if (_uploadProgresses == nil) {
		_uploadProgresses = [NSMutableDictionary dictionary];
	}
	
	return _uploadProgresses;
}

- (void)setUploadProgress:(float)progress forItem:(SKYItem *)item
{
	[self.uploadProgresses setObject:@(progress) forKey:item.objectID];
	[[NSNotificationCenter defaultCenter] postNotificationName:SKYUploadProgressDidChangeNotification
														object:item
													  userInfo:@{SKYInfoKeyForUploadProgress: @(progress)}
	 ];
}

- (float)uploadProgressForItem:(SKYItem *)item
{
	return [[self.uploadProgresses objectForKey:item.objectID] floatValue];
}

- (void)deleteAllEntries
{
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:SKYItemEntityName];
	fetchRequest.includesPropertyValues = NO;
	fetchRequest.includesSubentities = NO;
	
	NSError *error = nil;
	NSArray *items = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];

    if (error) {
        NSLog(@"Failed to fetch items from Core Data: %@", [error localizedDescription]);
    } else {
        NSLog(@"Deleting %lu items from Core Data", (unsigned long)items.count);
        for (NSManagedObject *managedObject in items) {
            [self.managedObjectContext deleteObject:managedObject];
        }
    }
	
	[self.managedObjectContext save:NULL];
}

- (void)reset
{
    [self.managedObjectContext reset];
}

- (SKYItem *)itemForURIRepresentation:(NSURL *)uri {
    NSManagedObjectID *objectId = [self.persistentStoreCoordinator managedObjectIDForURIRepresentation:uri];
    NSManagedObject *managedObject = [self.managedObjectContext existingObjectWithID:objectId error:nil];
    if (managedObject) {
        return (SKYItem *)managedObject;
    }
    return nil;
}

- (BOOL)obtainPermanentIDsForItems:(NSArray *)items {
    return [self.managedObjectContext obtainPermanentIDsForObjects:items error:nil];
}

@end

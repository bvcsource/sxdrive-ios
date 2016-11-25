//
//  SKYSingleFileBehaviourImplementation.m
//  SXDrive
//
//  Created by Skylable on 15/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYSingleFileBehaviourImplementation.h"

#import "NSFileManager+Extras.h"
#import "SKYFunctions.h"
#import "SKYInfoKeys.h"
#import "SKYItem+Extras.h"
#import "SKYNotificationNames.h"
#import "SKYPersistence.h"

@interface SKYSingleFileBehaviourImplementation () <NSFetchedResultsControllerDelegate>

/**
 * Item.
 */
@property (nonatomic, strong) SKYItem *item;

/**
 * Fetched results controller which checks the changes with frc.
 */
@property (nonatomic, strong) NSFetchedResultsController *frc;

/**
 * Displays the file.
 */
- (void)displayFile;

@end

@implementation SKYSingleFileBehaviourImplementation

@synthesize persistence = _persistence;
@synthesize syncService = _syncService;

- (void)processInfo:(NSDictionary *)info
{
	self.item = info[SKYInfoKeyForItem];
	self.frc = [self.persistence fetchedResultsControllerForItem:self.item];
	self.frc.delegate = self;
	[self.frc performFetch:NULL];
	
	[self.presenter displayBeforeViewForItem:self.item];
	
	if ([self.persistence isItemDownloaded:self.item] == YES) {
		[self displayFile];
	}
	else {
		[self.presenter displayProgress:[self.persistence downloadProgressForItem:self.item]];
	}
	
	__weak typeof(self) weakSelf = self;
	[[NSNotificationCenter defaultCenter] addObserverForName:SKYDownloadProgressDidChangeNotification object:self.item queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
		
		float percent = [note.userInfo[SKYInfoKeyForDownloadProgress] floatValue];
		
		[weakSelf.presenter displayProgress:percent];
		
		if (fEqual(percent, 1.f) == YES) {
			[weakSelf displayFile];
		}
	}];
	
	[self.syncService syncItem:self.item favourites:NO];
}

- (void)displayFile
{
	NSString *lowercaseExtension = [self.item.name pathExtension].lowercaseString;
	NSMutableArray *supportedExtensions = [NSMutableArray array];
	[supportedExtensions addObjectsFromArray:[NSFileManager imageExtensions]];
	[supportedExtensions addObjectsFromArray:[NSFileManager movieExtensions]];
	[supportedExtensions addObjectsFromArray:[NSFileManager musicExtensions]];
	
	NSArray *otherExtensions = @[@"pdf", @"xls", @"ppt", @"doc", @"docx", @"rtf", @"rtfd", @"key", @"numbers", @"pages", @"txt", @"c", @"h", @"m", @"mm"];
	[supportedExtensions addObjectsFromArray:otherExtensions];
	
	if ([supportedExtensions containsObject:lowercaseExtension] == YES) {
		[self.presenter displayFileContentsAtPath:[self.item expectedFileLocation]];
	}
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[self.syncService stopDownloadingItem:self.item];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{

}

@end

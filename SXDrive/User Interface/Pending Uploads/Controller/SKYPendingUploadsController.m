//
//  SKYPendingUploadsController.m
//  SXDrive
//
//  Created by Skylable on 16/11/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYPendingUploadsController.h"

#import "SKYInfoKeys.h"
#import "SKYItem+Extras.h"
#import "UIImage+SKYImage.h"
#import "NSByteCountFormatter+Extras.h"
#import "NSDateFormatter+Extras.h"

@interface SKYPendingUploadsController () <NSFetchedResultsControllerDelegate>

/**
 * Fetched Results Controller passed by behaviour to provide pending changes.
 */
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

/**
 * Property for accessing the browse directory view.
 */
@property (weak, nonatomic, readonly) UITableView <SKYPendingUploadsView> *pendingUploadsView;

/**
 * Property for accessing the browse directory behaviour.
 */
@property (weak, nonatomic, readonly) id <SKYPendingUploadsBehaviour> pendingUploadsBehaviour;

@end

@implementation SKYPendingUploadsController

@synthesize uploadsMode = _uploadsMode;

- (instancetype)initWithPendingUploadsView:(UITableView <SKYPendingUploadsView> *)pendingUploadsView pendingUploadsBehaviour:(id <SKYPendingUploadsBehaviour>)pendingUploadsBehaviour
{
	self = [super initWithView:pendingUploadsView behaviour:pendingUploadsBehaviour];
	
	if (self) {
        self.navigationItem.title = NSLocalizedString(@"Uploads", @"Title for uploads screen.");
	}
	
	return self;
}

#pragma mark - SKYPendingUploadsViewDataSource

- (NSInteger)numberOfItemSections {
    if (self.fetchedResultsController != nil) {
        return self.fetchedResultsController.sections.count;
    }
    return 0;
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    return sectionInfo.numberOfObjects;
}

- (BOOL)isRowAtIndexPathDirectory:(NSIndexPath *)indexPath
{
	SKYItem *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
	return (item.isDirectory.boolValue);
}

- (NSString *)nameOfItemAtIndexPath:(NSIndexPath *)indexPath
{
	SKYItem *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
	return item.name;
}

- (UIImage *)iconForItemAtIndexPath:(NSIndexPath *)indexPath
{
	SKYItem *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	return [UIImage iconImageForFileWithName:item.name isDirectory:item.isDirectory.boolValue];
}

- (float)progressForItemAtIndexPath:(NSIndexPath *)indexPath
{
	SKYItem *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	return [self.pendingUploadsBehaviour uploadProgressForItem:item];
}

- (NSString *)itemSectionTitle:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    return sectionInfo.name;
}

- (BOOL)uploadCompletedForItemAtIndexPath:(NSIndexPath *)indexPath {
    SKYItem *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return item.isUploadCompleted;
}

- (NSString *)pathForItemAtIndexPath:(NSIndexPath *)indexPath {
    SKYItem *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *path = [NSString stringWithString:item.path];
    if ([path hasPrefix:@"/"]) {
        path = [path substringWithRange:NSMakeRange(1, path.length - 1)];
    }
    if ([path hasSuffix:@"/"]) {
        path = [path substringToIndex:[path length] - 1];
    }
    return path;
}

- (NSString *)formattedSizeOfItemAtIndexPath:(NSIndexPath *)indexPath {
    SKYItem *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return [NSByteCountFormatter skyStringWithByteCount:item.fileSize.unsignedLongLongValue];
}

- (NSString *)modificationDateOfItemAtIndexPath:(NSIndexPath *)indexPath {
    SKYItem *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return [[NSDateFormatter dateFormatterForLastModificationDate] stringFromDate:item.updateDate];
}

#pragma mark - SKYPendingUploadsViewInteractionDelegate

- (void)userWantsToCancelUploadAtIndexPath:(NSIndexPath *)indexPath
{
	SKYItem *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
	[self.pendingUploadsBehaviour cancelUploadForItem:item];
}

- (NSString *)controllerUploadsMode {
    return self.uploadsMode;
}

- (void)userDidSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    SKYItem *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.pendingUploadsBehaviour userDidSelectItem:item];
}

#pragma mark - SKYPendingUploadsBehaviourPresenter

- (void)displayPendingChangesFromFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
{
	self.fetchedResultsController = fetchedResultsController;
	self.fetchedResultsController.delegate = self;
	[self.fetchedResultsController performFetch:nil];
	
	// Calling to use the same implementation.
	[self controllerDidChangeContent:self.fetchedResultsController];
}

- (void)displayProgress:(float)progress forItem:(SKYItem *)item
{
	NSUInteger index = [self.fetchedResultsController.fetchedObjects indexOfObject:item];

	if (index != NSNotFound) {
		[self.pendingUploadsView reloadData];
	}
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	[self.pendingUploadsView reloadData];
    
    NSInteger numberOfObjects = 0;
    if (self.fetchedResultsController.sections.count > 1) {
        id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[0];
        numberOfObjects = sectionInfo.numberOfObjects;
    }
    self.navigationController.tabBarItem.badgeValue = numberOfObjects > 0 ? [NSString stringWithFormat:@"%li", (long)numberOfObjects]:nil;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:numberOfObjects];
}

#pragma mark - Convenience accessors

- (UIView <SKYPendingUploadsView> *)pendingUploadsView
{
	return (UITableView <SKYPendingUploadsView> *)self.baseView;
}

- (id <SKYPendingUploadsBehaviour>)pendingUploadsBehaviour
{
	return (id <SKYPendingUploadsBehaviour>)self.baseBehaviour;
}

@end

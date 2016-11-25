//
//  SKYFavouritesController.m
//  SXDrive
//
//  Created by Skylable on 19/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYFavouritesController.h"

#import "NSByteCountFormatter+Extras.h"
#import "NSDateFormatter+Extras.h"
#import "SKYInfoKeys.h"
#import "SKYItem+Extras.h"
#import "SKYNoFavouritesCurtain.h"

@interface SKYFavouritesController () <NSFetchedResultsControllerDelegate>

/**
 * Property for accessing the browse directory view.
 */
@property (weak, nonatomic, readonly) UIView <SKYBrowseDirectoryView> *browseDirectoryView;

/**
 * Property for accessing the favourites behaviour.
 */
@property (weak, nonatomic, readonly) id <SKYFavouritesBehaviour> favouritesBehaviour;

/**
 * Fetched Results Controller passed by behaviour to provide favourites.
 */
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation SKYFavouritesController

- (instancetype)initWithBrowseDirectoryView:(UIView <SKYBrowseDirectoryView> *)browseDirectoryView favouritesBehaviour:(id <SKYFavouritesBehaviour>)favouritesBehaviour
{
	self = [super initWithView:browseDirectoryView behaviour:favouritesBehaviour];
	
	if (self) {
		self.navigationItem.title = NSLocalizedString(@"Favourites", @"Title for favourites screen.");
	}
	
	return self;
}

- (SKYViewType)viewType
{
	return SKYViewTypeFavourites;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.browseDirectoryView deselectSelectedCellAnimated:animated];
}

#pragma mark - SKYBrowseDirectoryViewDataSource methods

- (NSInteger)numberOfSections
{
	if (self.fetchedResultsController != nil) {
		return self.fetchedResultsController.sections.count;
	}
	else {
		return 0;
	}
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
	if (self.fetchedResultsController != nil) {
		if (self.fetchedResultsController.sections.count > 0) {
			id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
			return sectionInfo.numberOfObjects;
		}
		else {
			return 0;
		}
	}
	else {
		return 0;
	}
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

- (NSString *)formattedSizeOfItemAtIndexPath:(NSIndexPath *)indexPath
{
	SKYItem *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
	return [NSByteCountFormatter skyStringWithByteCount:item.fileSize.unsignedLongLongValue];
}

- (NSString *)modificationDateOfItemAtIndexPath:(NSIndexPath *)indexPath
{
	SKYItem *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	return [[NSDateFormatter dateFormatterForLastModificationDate] stringFromDate:item.updateDate];
}

- (SKYItem *)itemAtIndexPath:(NSIndexPath *)indexPath
{
	return [self.fetchedResultsController objectAtIndexPath:indexPath];
}

- (BOOL)isItemFavouritedAtIndexPath:(NSIndexPath *)indexPath
{
	SKYItem *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
	return item.isFavourite.boolValue;
}

- (BOOL)canEditItemAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}

- (BOOL)canShareItemAtIndexPath:(NSIndexPath *)indexPath {
    SKYItem *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return ![item.isDirectory boolValue];
}

- (BOOL)canShowRevisionsForItemAtIndexPath:(NSIndexPath *)indexPath {
    SKYItem *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return ![item.isDirectory boolValue];
}

#pragma mark - SKYBrowseDirectoryViewInteractionDelegate

- (void)userWantsToCreateDirectoryWithName:(NSString *)name
{
	NSAssert(NO, @"This method should not be called for favourites controller.");
}

- (void)userDidSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	[self.favouritesBehaviour userDidSelectItem:[self.fetchedResultsController objectAtIndexPath:indexPath]];
}

- (void)userWantsToDeleteItemAtIndexPaths:(NSArray *)indexPaths
{

}

- (NSString *)controllerBrowserMode {
    return SKYBrowserModeDefault;
}

- (void)userWantsToGetPublicLinkForItemAtIndexPath:(NSIndexPath *)indexPath {
    SKYItem *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.favouritesBehaviour generatePublicLinkForItem:item];
}

- (void)userWantsToShowRevisionsForItemAtIndexPath:(NSIndexPath *)indexPath {
    SKYItem *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.favouritesBehaviour showRevisionsForItem:item];
}

#pragma mark - SKYFavouritesBehaviourPresenter

- (void)displayFavouritesFromFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
{
	self.fetchedResultsController = fetchedResultsController;
	self.fetchedResultsController.delegate = self;
	[self.fetchedResultsController performFetch:nil];
	
	// Calling to use the same implementation.
	[self controllerDidChangeContent:self.fetchedResultsController];
}

#pragma mark - NSFetchedResultsControllerDelegate methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	[self.browseDirectoryView reloadData];
	
	if (controller.fetchedObjects.count == 0) {
		[self.browseDirectoryView displayCurtain:[SKYNoFavouritesCurtain new]];
	}
	else {
		[self.browseDirectoryView removeCurtain];
	}
}

#pragma mark - Convenience accessors

- (UIView <SKYBrowseDirectoryView> *)browseDirectoryView
{
	return (UIView <SKYBrowseDirectoryView> *)self.baseView;
}

- (id <SKYFavouritesBehaviour>)favouritesBehaviour
{
	return (id <SKYFavouritesBehaviour>)self.baseBehaviour;
}

@end

//
//  SKYVolumesController.m
//  SXDrive
//
//  Created by Skylable on 19/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYVolumesController.h"

#import "NSByteCountFormatter+Extras.h"
#import "SKYItem.h"
#import "SKYItem+Extras.h"
#import "SKYInfoKeys.h"
#import "SKYConfig.h"

@interface SKYVolumesController () <NSFetchedResultsControllerDelegate>

/**
 * Property for accessing the volumes view.
 */
@property (weak, nonatomic, readonly) UIView <SKYVolumesView> *volumesView;

/**
 * Property for accessing the volumes behaviour.
 */
@property (weak, nonatomic, readonly) id <SKYVolumesBehaviour> volumesBehaviour;

/**
 * Fetched Results Controller passed by behaviour to provide volumes.
 */
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

/**
 * Reloads title displayed on navigation bar.
 */
- (void)reloadTitle;

/**
 * Called when user presses cancel button in navigation bar while choosing directory.
 */
- (void)userDidCancelChoosingDirectory;

@end

@implementation SKYVolumesController

@synthesize browserMode = _browserMode;

- (instancetype)initWithVolumesView:(UIView <SKYVolumesView> *)volumesView volumesBehaviour:(id <SKYVolumesBehaviour>)volumesBehaviour
{
	self = [super initWithView:volumesView behaviour:volumesBehaviour];
	
	if (self) {
		self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    }
	
	return self;
}

- (SKYViewType)viewType
{
	return SKYViewTypeVolumes;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self.volumesView deselectSelectedVolumeCell];
	[self.volumesBehaviour startKeepingVolumesInSync];
    [self.volumesView.collectionView.collectionViewLayout invalidateLayout];
    [self.navigationController setToolbarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[self.volumesBehaviour stopKeepingVolumesInSync];
}

- (void)reloadTitle
{
	if (self.fetchedResultsController.fetchedObjects.count > 0) {
		NSString *title = NSLocalizedString(@"Volumes ([qty])", @"Title for volumes screen with quantity, [qty] is changed with quantity.");
		
		NSString *qtyString = [NSString stringWithFormat:@"%i", (int)self.fetchedResultsController.fetchedObjects.count];
		title = [title stringByReplacingOccurrencesOfString:@"[qty]" withString:qtyString];
		
		self.navigationItem.title = title;
	}
	else {
		self.navigationItem.title = NSLocalizedString(@"Volumes", @"Title for volumes screen without quantity.");
	}
}

- (void)userDidCancelChoosingDirectory {
    [self.volumesBehaviour userDidCancelChoosingDirectory];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[self.volumesView.collectionView.collectionViewLayout invalidateLayout];
}

#pragma mark - Convenience accessors

- (UIView <SKYVolumesView> *)volumesView
{
	return (UIView <SKYVolumesView> *)self.baseView;
}

- (id <SKYVolumesBehaviour>)volumesBehaviour
{
	return (id <SKYVolumesBehaviour>)self.baseBehaviour;
}

#pragma mark - SKYVolumesBehaviourPresenter

- (void)displayVolumesFromFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
{
	self.fetchedResultsController = fetchedResultsController;
	self.fetchedResultsController.delegate = self;
	[self.fetchedResultsController performFetch:nil];
	[self reloadTitle];
	
	if ([self.fetchedResultsController.fetchedObjects count] == 0) {
		//TOOD: displayEmptyView
	}
	else {
		//TODO: hideEmptyView
	}
}

- (void)displayToolsForChoosingDirectory {
    UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(userDidCancelChoosingDirectory)];
    [self.navigationItem setRightBarButtonItem:cancelBarButtonItem];
}

#pragma mark - NSFetchedResultsControllerDelegate methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	[self.volumesView reloadData];
	if (controller.fetchedObjects.count == 0) {
		//TOOD: display empty view
	}
	else {
		
	}
	
	[self reloadTitle];
    
    if ([SKYConfig importFileURL]) {
        [self.volumesBehaviour.viewNavigator displayImportFileInterfaceAnimated:YES];
    }
}

#pragma mark - SKYVolumesViewDataSource

- (NSInteger)numberOfVolumes
{
	return self.fetchedResultsController.fetchedObjects.count;
}

- (NSString *)titleForVolumeAtIndex:(NSInteger)index
{
	SKYItem *item = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
	return item.name;
}

- (NSString *)sizeForVolumeAtIndex:(NSInteger)index
{
	SKYItem *item = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
	return [NSByteCountFormatter skyStringWithByteCount:item.fileSize.unsignedLongLongValue];
}

- (BOOL)volumeWithTitleLocked:(NSString *)volumeTitle {
    BOOL canModify = [self.volumesBehaviour.persistence canModifyVolumeWithName:volumeTitle];
    return !canModify;
}

- (BOOL)volumeAtIndexEncrypted:(NSInteger)index {
    SKYItem *item = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    return [[item propertyValueForName:SKYPropertyNameFilterActive] length] > 0;
}

- (NSString *)volumBrowserMode {
    return self.browserMode;
}

#pragma mark - SKYVolumesViewInteractionDelegate

- (void)userDidSelectVolumeAtIndex:(NSInteger)index
{
    SKYItem *item = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    BOOL canModify = [self.volumesBehaviour.persistence canModifyVolumeWithName:item.name];
    if ([self.browserMode isEqualToString:SKYBrowserModeDefault] || canModify) {
        [self.volumesBehaviour userDidSelectVolume:[self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]]];
    }
}

@end

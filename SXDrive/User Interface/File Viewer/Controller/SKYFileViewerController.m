//
//  SKYFileViewerController.m
//  SXDrive
//
//  Created by Skylable on 19.09.2014.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

@import QuickLook;
@import MediaPlayer;

#import "SKYFileViewerController.h"

#import "SKYItem+Extras.h"
#import "SKYNotificationNames.h"
#import "SKYSingleFileInjector.h"
#import "UIDevice+ScreenSize.h"

@interface SKYFileViewerController () <NSFetchedResultsControllerDelegate>

/**
 * Property for accessing the file viewer view.
 */
@property (weak, nonatomic, readonly) UIView <SKYFileViewerView> *fileViewerView;

/**
 * Property for accessing the file viwer behaviour.
 */
@property (weak, nonatomic, readonly) id <SKYFileViewerBehaviour> fileViewerBehaviour;

/**
 * Fetched Results Controller passed by behaviour to provide files.
 */
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

/**
 * Keeps single viewer controllers in memory.
 */
@property (nonatomic, strong) NSMutableArray *singleViewerControllers;

/**
 * Block of operations containing various updates to perform on view's collection view.
 */
@property (nonatomic, strong) NSBlockOperation *collectionViewUpdatesBlock;

/**
 * Interaction controller.
 */
@property (nonatomic, strong) UIDocumentInteractionController *interactionController;

/**
 * Helper property for rotation.
 */
@property (nonatomic) NSInteger currentIndex;

@end

@interface SKYFileViewerController ()

- (void)_willRotate;
- (void)_didRotate;

@end

@implementation SKYFileViewerController

- (instancetype)initWithFileViewerView:(UIView<SKYFileViewerView> *)fileViewerView fileViewerBehaviour:(id<SKYFileViewerBehaviour>)fileViewerBehaviour
{
	self = [super initWithView:fileViewerView behaviour:fileViewerBehaviour];

	if (self) {
		self.hidesBottomBarWhenPushed = YES;
		self.swipeToPopGestureEnabled = NO;
	}
	
	return self;
}

- (SKYViewType)viewType
{
	return SKYViewTypeFileViewer;
}

- (NSMutableArray *)singleViewerControllers
{
	if (_singleViewerControllers == nil) {
		_singleViewerControllers = [NSMutableArray array];
	}
	
	return _singleViewerControllers;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.automaticallyAdjustsScrollViewInsets = NO;
	
	__weak typeof(self) weakSelf = self;
	[[NSNotificationCenter defaultCenter] addObserverForName:SKYPlayMediaInExternalVCNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
		MPMoviePlayerViewController *vc = [[MPMoviePlayerViewController alloc] initWithContentURL:note.object];
		[weakSelf presentMoviePlayerViewControllerAnimated:vc];
	}];
}

#pragma mark - Convenience accessors

- (UIView <SKYFileViewerView> *)fileViewerView
{
	return (UIView <SKYFileViewerView> *)self.baseView;
}

- (id <SKYFileViewerBehaviour>)fileViewerBehaviour
{
	return (id <SKYFileViewerBehaviour>)self.baseBehaviour;
}

#pragma mark - SKYFileViewerViewDataSource methods

- (NSInteger)numberOfItems
{
	if (self.fetchedResultsController != nil) {
		if (self.fetchedResultsController.sections.count > 0) {
			id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[0];
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

- (UIView *)fileViewForItemAtIndex:(NSInteger)index
{
	SKYItem *item = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
	id <SKYBaseController> vc = [SKYSingleFileInjector injectViewControllerWithItem:item];
	[self.singleViewerControllers addObject:vc];
	
	return [vc viewControler].view;
}

- (BOOL)isItemFavouritedAtIndex:(NSInteger)index
{
	SKYItem *item = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
	
	return item.isFavourite.boolValue;
}

#pragma mark - SKYFileViewerViewInteractionDelegate methods

- (void)userDidScrollToItemAtIndex:(NSUInteger)index
{
	SKYItem *item = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
	
	if (item != nil) {
		self.navigationItem.title = item.name;
	}
	
	self.currentIndex = index;
}

- (void)userScrolledFileViewBeyondVisibleArea:(UIView *)fileView
{
	id <SKYBaseController> vcToDelete = nil;
	for (id <SKYBaseController> vc in self.singleViewerControllers) {
		if ([vc viewControler].view == fileView) {
			vcToDelete = vc;
			break;
		}
	}
	if (vcToDelete != nil) {
		[self.singleViewerControllers removeObject:vcToDelete];
	}
}

- (void)userWantsToReverseFavouriteStatusOfItemAtIndex:(NSUInteger)index
{
	[self.fileViewerBehaviour reverseFavouriteStatus:[self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]]];
}

- (void)userWantsToShareItemAtIndex:(NSUInteger)index
{
	SKYItem *item = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
	[self.fileViewerBehaviour shareItem:item];
}

- (void)userWantsToGetPublicLinkForItemAtIndexPath:(NSIndexPath *)indexPath {
    SKYItem *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.fileViewerBehaviour generatePublicLinkForItem:item];
}

- (void)userWantsToDeleteItemAtIndex:(NSUInteger)index
{
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:[[UIDevice currentDevice] screenSize] == UIDeviceScreenSizePad ? UIAlertControllerStyleAlert:UIAlertControllerStyleActionSheet];
	
	[alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Delete", @"Generic delete") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
		SKYItem *item = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
		[self.fileViewerBehaviour deleteItem:item];
	}]];
	
	[alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Generic cancel") style:UIAlertActionStyleCancel handler:nil]];
	
	[self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - SKYFileViewerBehaviourPresenter

- (void)displayItem:(SKYItem *)item andOtherFilesFromFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
{
	self.fetchedResultsController = fetchedResultsController;
	self.fetchedResultsController.delegate = self;
	[self.fetchedResultsController performFetch:nil];
	
	NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:item];
	
	[self.fileViewerView reloadFavouriteStatusOfItemAtIndex:indexPath.row];
	self.fileViewerView.indexPathToFocus = indexPath;
	
	if ([self.fetchedResultsController.fetchedObjects count] == 0) {
		//TOOD: displayEmptyView
	}
	else {
		//TODO: hideEmptyView
	}
	
	self.navigationItem.title = item.name;
}

- (void)displayShareMenuForItem:(SKYItem *)item
{
	self.interactionController = [UIDocumentInteractionController interactionControllerWithURL:item.expectedFileURL];
	
	UIBarButtonItem *barButton = [self.fileViewerView shareButtonItem];
	[self.interactionController presentOptionsMenuFromBarButtonItem:barButton animated:YES];
}

- (void)displayShareUnavailableBecauseOfNotDownloadedFile:(SKYItem *)item
{
	[self.fileViewerView displayShareUnavailableBecauseOfNotDownloadedFile];
}

#pragma mark - NSFetchedResultsControllerDelegate methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
	self.collectionViewUpdatesBlock = [NSBlockOperation new];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath
{
	if (type == NSFetchedResultsChangeInsert) {
		__weak SKYFileViewerController *weakSelf = self;
		[self.collectionViewUpdatesBlock addExecutionBlock:^{
			[weakSelf.fileViewerView.collectionView insertItemsAtIndexPaths:@[newIndexPath]];
		}];
	}
	else if (type == NSFetchedResultsChangeDelete) {
		
		if (controller.fetchedObjects.count != 0) {
			__weak SKYFileViewerController *weakSelf = self;
			[self.collectionViewUpdatesBlock addExecutionBlock:^{
				[weakSelf.fileViewerView.collectionView deleteItemsAtIndexPaths:@[indexPath]];
			}];
		}
		else {
			[self.fileViewerBehaviour performActionForNoMoreItemsToDisplay];
		}
	}
	else if (type == NSFetchedResultsChangeMove) {
		__weak SKYFileViewerController *weakSelf = self;
		[self.collectionViewUpdatesBlock addExecutionBlock:^{
			[weakSelf.fileViewerView.collectionView moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
		}];
	}
	else if (type == NSFetchedResultsChangeUpdate) {
		[self.fileViewerView reloadFavouriteStatusOfItemAtIndex:indexPath.row];
	}
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	if (controller.fetchedObjects.count == 0) {
		//TOOD: pop to previous controller
	}
	else {
		[self.fileViewerView.collectionView performBatchUpdates:^{
			[self.collectionViewUpdatesBlock start];
		} completion:nil];
	}
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self _willRotate];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    [self _didRotate];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [self _willRotate];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
     } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
         [self _didRotate];
     }];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self.fileViewerView performSelector:@selector(updateFavouriteButtonItem) withObject:nil afterDelay:0.05];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private

- (void)_willRotate {
    self.fileViewerView.scrollLocked = YES;
    
    [self.fileViewerView.collectionView.collectionViewLayout invalidateLayout];
    
    NSArray *array = [self.fileViewerView.collectionView indexPathsForVisibleItems];
    if ([array count] > 0) {
        NSIndexPath *visibleIndexPath = (NSIndexPath *)[array objectAtIndex:0];
        self.currentIndex = visibleIndexPath.row;
    }
    
    [self.fileViewerView.collectionView setAlpha:0.0f];
}

- (void)_didRotate {
    [self.fileViewerView.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    
    [UIView animateWithDuration:0.125f animations:^{
        [self.fileViewerView.collectionView setAlpha:1.0f];
    }];
    
    self.fileViewerView.scrollLocked = NO;
}

@end

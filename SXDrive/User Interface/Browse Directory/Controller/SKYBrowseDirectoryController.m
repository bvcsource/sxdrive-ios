//
//  SKYBrowseDirectoryController.m
//  SXDrive
//
//  Created by Skylable on 17/09/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

@import MobileCoreServices;

#import "SKYBrowseDirectoryController.h"

#import "NSByteCountFormatter+Extras.h"
#import "NSDateFormatter+Extras.h"
#import "SKYAddContentOverlay.h"
#import "SKYBrowseDirectoryMultipleSelectionBottomBar.h"
#import "SKYConfig.h"
#import "SKYInfoKeys.h"
#import "SKYUserImplementation.h"
#import "SKYItem+Extras.h"
#import "SKYMoreActionsOverlay.h"
#import "SKYNavigationController.h"
#import "SKYPendingUploadsController.h"
#import "SKYPendingUploadsView.h"
#import "UIColor+SKYColor.h"
#import "UIFont+SKYFont.h"
#import "UIDevice+ScreenSize.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "SKYNotificationNames.h"
#import "ELCImagePickerController.h"

#import <SSKeychain/SSKeychain.h>

@interface SKYBrowseDirectoryController () <NSFetchedResultsControllerDelegate, ELCImagePickerControllerDelegate, UINavigationControllerDelegate, SKYAddContentOverlayDelegate, SKYMoreActionsOverlayDelegate, SKYBrowseDirectoryMultipleSelectionBottomBarDelegate>

/**
 * Property for accessing the browse directory view.
 */
@property (weak, nonatomic, readonly) UIView <SKYBrowseDirectoryView> *browseDirectoryView;

/**
 * Property for accessing the browse directory behaviour.
 */
@property (weak, nonatomic, readonly) id <SKYBrowseDirectoryBehaviour> browseDirectoryBehaviour;

/**
 * Fetched Results Controller passed by behaviour to provide listing.
 */
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

/**
 * Defines if user can modify the content.
 */
@property (nonatomic) BOOL hasWriteAccessRight;

/**
 * Pending uploads controller.
 */
@property (nonatomic) SKYPendingUploadsController *pendingUploadsController;

/**
 * Array keeping selected items.
 */
@property (nonatomic, strong) NSMutableArray *selectedItems;

/**
 * Multiple selection bottom bar.
 */
@property (nonatomic, strong) SKYBrowseDirectoryMultipleSelectionBottomBar *multipleSelectionBottomBar;

/**
 * New directory index path.
 */
@property (nonatomic, strong) NSIndexPath *directoryIndexPath;

/**
 * Indicates that user wants to create a directory.
 * So, as soon as the directory is created application navigates to this directory programmatically.
 */
@property (nonatomic, assign) BOOL creatingDirectory;

/**
 * Array keeping info dictionaries pending to upload.
 */
@property (nonatomic, retain) NSMutableArray *pendingInfoArray;

/**
 * Timer to upload items one-by-one with a small delay.
 */
@property (nonatomic, retain) NSTimer *uploadTimer;

/**
 * Called when user presses add button in navigation bar.
 */
- (void)userDidPressAddButton;

/**
 * Called when user presses more button in navigation bar.
 */
- (void)userDidPressMoreButton;

/**
 * Called when user presses cancel to cancel selection.
 */
- (void)userDidPressCancelSelection;

/**
 * Hides selection state.
 */
- (void)revertsSelectionState;

/**
 * Displays image picker controller to pick photos and videos.
 */
- (void)displayImagePickerController;

/**
 * Reloads title, displays either directoryTitle property or number of selected items.
 */
- (void)reloadTitle;

/**
 * Called when user presses choose directory button in toolbar.
 */
- (void)userDidChooseDirectory;

/**
 * Called when user presses cancel button in navigation bar while choosing directory.
 */
- (void)userDidCancelChoosingDirectory;

/**
 * Called when user wants to add new Directory
 */
- (void)addNewDirectory;

/**
 * Start upload pending items.
 */
- (void)startUploadPendingItems;

/**
 * Adds new file from array of items pending to upload.
 */
- (void)addFileFromPendingItems;

/**
 * Add new file with date created.
 */
- (void)addFile:(NSDictionary *)file withDate:(NSDate *)date;

@end

@implementation SKYBrowseDirectoryController

@synthesize directoryTitle = _directoryTitle;
@synthesize browserMode = _browserMode;

- (instancetype)initWithBrowseDirectoryView:(UITableView <SKYBrowseDirectoryView> *)browseDirectoryView browseDirectoryBehaviour:(id <SKYBrowseDirectoryBehaviour>)browseDirectoryBehaviour
{
	self = [super initWithView:browseDirectoryView behaviour:browseDirectoryBehaviour];
	
	if (self) {

	}
	
	return self;
}

- (SKYViewType)viewType
{
	return SKYViewTypeBrowseDirectory;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.browseDirectoryView deselectSelectedCellAnimated:animated];
	[self.browseDirectoryBehaviour startKeepingDirectoryInSync];
    
    if ([self.browserMode isEqualToString:SKYBrowserModeChooseDirectory]) {
        [self.browseDirectoryBehaviour updateDirectory];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[self.browseDirectoryBehaviour stopKeepingDirectoryInSync];
}

- (void)setDirectoryTitle:(NSString *)directoryTitle
{
	_directoryTitle = directoryTitle;
	[self reloadTitle];
}

- (void)reloadTitle
{
	if (self.selectedItems != nil) {
		NSString *title = NSLocalizedString(@"Selected: [count]", @"Title for browse directory when user can select items, [count] changes to number of selected items.");
		title = [title stringByReplacingOccurrencesOfString:@"[count]" withString:[NSString stringWithFormat:@"%i", (int)self.selectedItems.count]];
		self.navigationItem.title = title;
	}
	else {
		self.navigationItem.title = self.directoryTitle;
	}
}

- (void)userDidPressAddButton
{
	SKYAddContentOverlay *overlay = [SKYAddContentOverlay new];
	overlay.delegate = self;
	overlay.navigationBar = self.navigationController.navigationBar;
	overlay.translatesAutoresizingMaskIntoConstraints = NO;
	[self.tabBarController.view addSubview:overlay];
	[self.tabBarController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": overlay}]];
	[self.tabBarController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view": overlay}]];
	[overlay displayArrowWithCenterAtDistanceFromRightEdge:55.f];
	[overlay animateEntry];
}

- (void)userDidPressMoreButton
{
	SKYMoreActionsOverlay *overlay = [SKYMoreActionsOverlay new];
	overlay.presentingViewController = self;
	overlay.delegate = self;
	overlay.navigationBar = self.navigationController.navigationBar;
	overlay.translatesAutoresizingMaskIntoConstraints = NO;
	[self.tabBarController.view addSubview:overlay];
	[self.tabBarController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": overlay}]];
	[self.tabBarController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view": overlay}]];
	[overlay displayArrowWithCenterAtDistanceFromRightEdge:15.f];
	[overlay animateEntry];
}

- (void)userDidPressCancelSelection
{
	[self revertsSelectionState];
}

- (void)revertsSelectionState
{
	self.selectedItems = nil;
	[self reloadTitle];
	[self.navigationItem setLeftBarButtonItem:nil animated:YES];
	[self displayToolsForUserWithWriteAccessRight];
	
	[self.browseDirectoryView hideSelectionView];
	
	[UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
		self.multipleSelectionBottomBar.alpha = 0.f;
	} completion:^(BOOL finished) {
		[self.multipleSelectionBottomBar removeFromSuperview];
		self.multipleSelectionBottomBar = nil;
	}];
}

- (void)displayImagePickerController
{
    ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initImagePicker];
    elcPicker.maximumImagesCount = 10;
    elcPicker.returnsOriginalImage = YES;
    elcPicker.returnsImage = YES;
    elcPicker.onOrder = YES;
    elcPicker.imagePickerDelegate = self;
    
    UINavigationBar *navigationBar = elcPicker.navigationBar;
    navigationBar.barTintColor = [UIColor skyMainColor];
    navigationBar.tintColor = [UIColor whiteColor];
    navigationBar.opaque = YES;
    navigationBar.translucent = NO;
    navigationBar.barStyle = UIBarStyleBlack;
    [navigationBar setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontForBarTexts]}];
    
    if ([[UIDevice currentDevice] screenSize] == UIDeviceScreenSizePad) {
        UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:elcPicker];
        popoverController.backgroundColor = [UIColor skyMainColor];
        [popoverController presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    } else {
        [self presentViewController:elcPicker animated:YES completion:nil];
    }
    
}

- (void)userDidChooseDirectory {
    [self.browseDirectoryBehaviour userDidChooseDirectory];
}

- (void)userDidCancelChoosingDirectory {
    [self.browseDirectoryBehaviour userDidCancelChoosingDirectory];
}

- (void)addNewDirectory {
    [self.browseDirectoryView displayAddNewDirectoryInterface];
}

- (void)startUploadPendingItems {
    self.uploadTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(addFileFromPendingItems) userInfo:nil repeats:YES];
}

- (void)addFileFromPendingItems {
    if ([self.pendingInfoArray count] > 0) {
        NSDictionary *info = [self.pendingInfoArray firstObject];
        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
        if (info[UIImagePickerControllerMediaType] == ALAssetTypePhoto) {
            NSURL *assetURL = info[UIImagePickerControllerReferenceURL];
            NSString *type = [assetURL pathExtension];
            NSDictionary *fileDictionary = @{
                                             SKYInfoKeyForImage: info[UIImagePickerControllerOriginalImage],
                                             SKYInfoKeyForImageType: type
                                             };
            [assetsLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                NSDate *date = [asset valueForProperty:ALAssetPropertyDate];
                [self addFile:fileDictionary withDate:date];
            } failureBlock:^(NSError *error){
                [self addFile:fileDictionary withDate:nil];
            }];
        } else if (info[UIImagePickerControllerMediaType] == ALAssetTypeVideo) {
            [assetsLibrary assetForURL:info[UIImagePickerControllerReferenceURL] resultBlock:^(ALAsset *asset) {
                Byte *buffer = (Byte*)malloc((NSUInteger)asset.defaultRepresentation.size);
                NSUInteger buffered = [asset.defaultRepresentation getBytes:buffer fromOffset:0.0 length:(NSUInteger)asset.defaultRepresentation.size error:nil];
                NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
                NSDate *date = [asset valueForProperty:ALAssetPropertyDate];
                NSDictionary *fileDictionary = @{
                                                 SKYInfoKeyForMovieURL: data,
                                                 };
                [self addFile:fileDictionary withDate:date];
            } failureBlock:^(NSError *error){
            }];

        }
        [self.pendingInfoArray removeObjectAtIndex:0];
    } else {
        [self.uploadTimer invalidate];
        self.uploadTimer = nil;
    }
}

- (void)addFile:(NSDictionary *)file withDate:(NSDate *)date {
    NSMutableDictionary *fileDictionary = [NSMutableDictionary dictionaryWithDictionary:file];
    if (date) {
        [fileDictionary setObject:date forKey:SKYInfoKeyForAssetDate];
    }
    [self.browseDirectoryBehaviour addFile:[NSDictionary dictionaryWithDictionary:fileDictionary]];
}

#pragma mark - SKYAddContentOverlayDelegate

- (void)addContentOverlayDidChooseAddNewDirectory:(SKYAddContentOverlay *)overlay
{
	[self addNewDirectory];
}

- (void)addContentOverlayDidChooseAddNewFile:(SKYAddContentOverlay *)overlay
{
	[self displayImagePickerController];
}

#pragma mark - SKYMoreActionsOverlayDelegate

- (void)moreActionsOverlay:(SKYMoreActionsOverlay *)overlay didChangeSortingType:(SKYConfigSortingType)sortingType
{
	[self.browseDirectoryBehaviour changeSortingType:sortingType];
}

- (void)moreActionsOverlayDidChangeSelectingState:(SKYMoreActionsOverlay *)overlay
{
	self.selectedItems = [NSMutableArray array];
	[self reloadTitle];
	
	[self.browseDirectoryView showSelectionView];
	
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(userDidPressCancelSelection)];
	[self.navigationItem setLeftBarButtonItem:cancelButton animated:YES];
	[self.navigationItem setRightBarButtonItem:nil animated:YES];
	
	self.multipleSelectionBottomBar = [SKYBrowseDirectoryMultipleSelectionBottomBar new];
	self.multipleSelectionBottomBar.translatesAutoresizingMaskIntoConstraints = NO;
	self.multipleSelectionBottomBar.delegate = self;
	[self.tabBarController.view addSubview:self.multipleSelectionBottomBar];
	[self.tabBarController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bar]|" options:0 metrics:nil views:@{@"bar": self.multipleSelectionBottomBar}]];
	[self.tabBarController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bar]|" options:0 metrics:nil views:@{@"bar": self.multipleSelectionBottomBar}]];
	
	self.multipleSelectionBottomBar.alpha = 0.f;
	[UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
		self.multipleSelectionBottomBar.alpha = 1.f;
	} completion:nil];
}

#pragma mark - SKYBrowseDirectoryMultipleSelectionBottomBarDelegate

- (void)multipleSelectionBottomBarDidPressDelete:(SKYBrowseDirectoryMultipleSelectionBottomBar *)multipleSelectionBottomBar
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:[[UIDevice currentDevice] screenSize] == UIDeviceScreenSizePad ? UIAlertControllerStyleAlert:UIAlertControllerStyleActionSheet];
	
	[alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Delete", @"Generic delete") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
		[self.browseDirectoryBehaviour deleteItems:self.selectedItems];
		
		[self revertsSelectionState];
	}]];
	
	[alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Generic cancel") style:UIAlertActionStyleCancel handler:nil]];
	
	[self presentViewController:alert animated:YES completion:nil];
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
			id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
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
	return self.hasWriteAccessRight == YES;
}

- (BOOL)canShareItemAtIndexPath:(NSIndexPath *)indexPath {
    if([SSKeychain passwordForService:SKYUserKeychainSXDriveService account:SKYUserKeychainSXShareAccount])
        return true;
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
    self.creatingDirectory = YES;
	[self.browseDirectoryBehaviour createDirectoryWithName:name];
}

- (void)userDidSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	SKYItem *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	if (self.selectedItems != nil) {
		if ([self.selectedItems containsObject:item] == YES) {
			[self.selectedItems removeObject:item];
		}
		else {
			[self.selectedItems addObject:item];
		}
		
		[self.multipleSelectionBottomBar setControlsEnabled:(self.selectedItems.count > 0)];
		
		[self reloadTitle];
	}
	else {
		[self.browseDirectoryBehaviour userDidSelectItem:item];
	}
}

- (void)userWantsToDeleteItemAtIndexPaths:(NSArray *)indexPaths
{
	NSMutableArray *itemsToDelete = [NSMutableArray array];
	for (NSIndexPath *indexPath in indexPaths) {
		[itemsToDelete addObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
	}
	
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:[[UIDevice currentDevice] screenSize] == UIDeviceScreenSizePad ? UIAlertControllerStyleAlert:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Delete", @"Generic delete") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self.browseDirectoryBehaviour deleteItems:itemsToDelete];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Generic cancel") style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (NSString *)controllerBrowserMode {
    return self.browserMode;
}

- (void)userWantsToGetPublicLinkForItemAtIndexPath:(NSIndexPath *)indexPath {
    SKYItem *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.browseDirectoryBehaviour generatePublicLinkForItem:item];
}

- (void)userWantsToShowRevisionsForItemAtIndexPath:(NSIndexPath *)indexPath {
    SKYItem *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.browseDirectoryBehaviour showRevisionsForItem:item];
}

#pragma mark - SKYBrowseDirectoryBehaviourPresenter

- (void)displayLoadingIndicator:(BOOL)display
{
	if (self.refreshControl == nil) {
		self.refreshControl = [[UIRefreshControl alloc] init];
		[self.refreshControl addTarget:self.browseDirectoryBehaviour action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
	}
	
	if (display == YES) {
		[self.refreshControl beginRefreshing];
	}
	else {
		[self.refreshControl endRefreshing];
	}
}

- (void)displayDirectoryListingFromFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
{
	[self.browseDirectoryView removeCurtain];
	
	if (self.fetchedResultsController != nil) {
		self.fetchedResultsController.delegate = nil;
		self.fetchedResultsController = nil;
	}
	
	self.fetchedResultsController = fetchedResultsController;
	self.fetchedResultsController.delegate = self;
	[self.fetchedResultsController performFetch:nil];
	
	// Calling to use the same implementation.
	[self controllerDidChangeContent:self.fetchedResultsController];
}

- (void)displayPendingUploadsController:(SKYPendingUploadsController *)pendingUploadsController
{
	self.pendingUploadsController = pendingUploadsController;
	[self.browseDirectoryView addPendingUpdatesView:(id <SKYPendingUploadsView>)[pendingUploadsController viewControler].view];
}

- (void)displayLoadingInterface
{
	self.refreshControl = nil;
	[self.browseDirectoryView displayLoadingSpinner];
}

- (void)displayNoInternetInterface
{
	self.refreshControl = nil;
	[self.browseDirectoryView displayNoInternetLabel];
}

- (void)displayToolsForUserWithWriteAccessRight
{
	self.hasWriteAccessRight = YES;
	
	UIView *barButtonsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 66, 44)];
	barButtonsView.translatesAutoresizingMaskIntoConstraints = NO;
	
	UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
	addButton.frame = CGRectMake(0, 0, 30, 44);
	[addButton setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
	[addButton addTarget:self action:@selector(userDidPressAddButton) forControlEvents:UIControlEventTouchUpInside];
	[barButtonsView addSubview:addButton];
	
	UIImage *moreImage = [UIImage imageNamed:@"more"];
	UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
	moreButton.frame = CGRectMake(barButtonsView.frame.size.width - moreImage.size.width, 0, moreImage.size.width, 44);
	[moreButton setImage:moreImage forState:UIControlStateNormal];
	[moreButton addTarget:self action:@selector(userDidPressMoreButton) forControlEvents:UIControlEventTouchUpInside];
	[barButtonsView addSubview:moreButton];
	
	[self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:barButtonsView] animated:YES];
}

- (void)displayToolsForChoosingDirectory {
    [self.navigationController setToolbarHidden:NO];
    
    UIBarButtonItem *chooseDirectoryBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Choose", @"Choose directory to import file interface") style:UIBarButtonItemStylePlain target:self action:@selector(userDidChooseDirectory)];
    [self.navigationItem setRightBarButtonItem:chooseDirectoryBarButtonItem];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *addNewDirectoryBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Add new folder", @"Choose directory to import file interface") style:UIBarButtonItemStylePlain target:self action:@selector(addNewDirectory)];
    UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(userDidCancelChoosingDirectory)];
    self.toolbarItems = [NSArray arrayWithObjects:addNewDirectoryBarButtonItem, flexibleSpace, cancelBarButtonItem, nil];
}

#pragma mark - NSFetchedResultsControllerDelegate methods



- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	[self.browseDirectoryView reloadData];
	if (controller.fetchedObjects.count == 0) {
		[self.browseDirectoryView displayEmptyDirectoryLabel];
	}
	else {
		[self.browseDirectoryView displaysFiles];
        if (self.directoryIndexPath && self.creatingDirectory) {
            [self.browseDirectoryView selectRowAtIndexPath:self.directoryIndexPath];
            self.directoryIndexPath = nil;
            self.creatingDirectory = NO;
        }
	}
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    if (type == NSFetchedResultsChangeInsert && self.creatingDirectory) {
        self.directoryIndexPath = newIndexPath;
    }
}

#pragma mark - Convenience accessors

- (UIView <SKYBrowseDirectoryView> *)browseDirectoryView
{
	return (UIView <SKYBrowseDirectoryView> *)self.baseView;
}

- (id <SKYBrowseDirectoryBehaviour>)browseDirectoryBehaviour
{
	return (id <SKYBrowseDirectoryBehaviour>)self.baseBehaviour;
}

#pragma mark - ELCImagePickerControllerDelegate

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)infoArray {
    [picker dismissViewControllerAnimated:YES completion:^{
        self.pendingInfoArray = [NSMutableArray arrayWithArray:infoArray];
        [self startUploadPendingItems];
    }];
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation controller delegate

-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

@end

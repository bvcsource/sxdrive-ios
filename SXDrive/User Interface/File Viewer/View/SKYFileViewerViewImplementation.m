//
//  SKYFileViewerViewImplementation.m
//  SXDrive
//
//  Created by Skylable on 19.09.2014.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYFileViewerViewImplementation.h"

#import "NSArray+Extras.h"
#import "SKYFileViewerCollectionView.h"
#import "SKYFileViewerCollectionViewLayout.h"
#import "SKYFileViewerFileViewCollectionCell.h"
#import "UIColor+SKYColor.h"

@interface SKYFileViewerViewImplementation () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

/**
 * Collevion view's layout.
 */
@property (nonatomic, strong) UICollectionViewFlowLayout *collectionViewFlowLayout;

/**
 * Toolbar with file options like favoruties, delete, share.
 */
@property (nonatomic, strong) UIToolbar *toolbar;

/**
 * Favourite bar button item.
 */
@property (nonatomic, strong) UIBarButtonItem *favouriteButtonItem;

/**
 * Public link button item.
 */
@property (nonatomic, strong) UIBarButtonItem *publicLinkButtonItem;

/**
 * Called when user presses the star button.
 */
- (void)userDidPressStarButton;

/**
 * Called when user presses the public link button.
 */
- (void)userDidPressPublicLinkButton;

/**
 * Called when user presses the action button.
 */
- (void)userDidPressShareButton;

/**
 * Called when user presses the trash button.
 */
- (void)userDidPressTrashButton;

@end

@implementation SKYFileViewerViewImplementation

@synthesize interactionDelegate = _interactionDelegate;
@synthesize dataSource = _dataSource;
@synthesize collectionView = _collectionView;
@synthesize indexPathToFocus = _indexPathToFocus;
@synthesize shareButtonItem = _shareButtonItem;
@synthesize scrollLocked = _scrollLocked;

- (void)createSubviews
{
	self.backgroundColor = [UIColor whiteColor];

	self.collectionViewFlowLayout = [SKYFileViewerCollectionViewLayout new];
	self.collectionViewFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

	self.collectionView = [[SKYFileViewerCollectionView alloc] initWithFrame:CGRectZero
														collectionViewLayout:self.collectionViewFlowLayout];
	self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
	self.collectionView.backgroundColor = [UIColor whiteColor];
	self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
	[self.collectionView registerClass:[SKYFileViewerFileViewCollectionCell class] forCellWithReuseIdentifier:SKYFileViewerFileViewCollectionCellReuseIdentifier];
	self.collectionView.delegate = self;
	self.collectionView.dataSource = self;
	[self addSubview:self.collectionView];
	
	UIBarButtonItem *spacer1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	UIBarButtonItem *spacer2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

	self.shareButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(userDidPressShareButton)];
    self.publicLinkButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"pub-link-tab"] style:UIBarButtonItemStylePlain target:self action:@selector(userDidPressPublicLinkButton)];
	self.favouriteButtonItem = [[UIBarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStylePlain target:self action:@selector(userDidPressStarButton)];
	UIBarButtonItem *trashButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(userDidPressTrashButton)];
	trashButtonItem.tintColor = [UIColor skyColorForDelete];
		
	self.toolbar = [[UIToolbar alloc] init];
	self.toolbar.translatesAutoresizingMaskIntoConstraints = NO;
	self.toolbar.items = @[self.shareButtonItem, spacer1, self.publicLinkButtonItem, spacer1, self.favouriteButtonItem, spacer2, trashButtonItem];
	[self addSubview:self.toolbar];
	
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bar]|" options:0 metrics:nil views:@{@"bar": self.toolbar}]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": self.collectionView}]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view][bar]|" options:0 metrics:nil views:@{@"view": self.collectionView, @"bar": self.toolbar}]];
	
	[self updateFavouriteButtonItem];
}

- (void)updateFavouriteButtonItem
{
	BOOL isFavourite = [self.dataSource isItemFavouritedAtIndex:self.collectionView.currentPage];
	
	if (isFavourite == YES) {
		self.favouriteButtonItem.image = [[UIImage imageNamed:@"favs-add-focus"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
	}
	else {
		self.favouriteButtonItem.image = [[UIImage imageNamed:@"favs-add-tab"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
	}
}

- (void)reloadFavouriteStatusOfItemAtIndex:(NSInteger)index
{
	if (self.collectionView.currentPage == index) {
		[self updateFavouriteButtonItem];
	}
}

- (void)userDidPressStarButton
{
	[self.interactionDelegate userWantsToReverseFavouriteStatusOfItemAtIndex:self.collectionView.currentPage];
}

- (void)userDidPressShareButton
{
	[self.interactionDelegate userWantsToShareItemAtIndex:self.collectionView.currentPage];
}

- (void)userDidPressPublicLinkButton {
    [self.interactionDelegate userWantsToGetPublicLinkForItemAtIndexPath:[NSIndexPath indexPathForRow:self.collectionView.currentPage inSection:0]];
}

- (void)userDidPressTrashButton
{
	[self.interactionDelegate userWantsToDeleteItemAtIndex:self.collectionView.currentPage];
}

- (void)displayShareUnavailableBecauseOfNotDownloadedFile
{
	NSString *localizedTitle = NSLocalizedString(@"Cannot share right now", @"Title for alert when the share is currently unavailable, because download has not finished yet.");
	NSString *localizedMessage = NSLocalizedString(@"You will be able to share once the file has been downloaded.", @"Message for alert when the share is currently unavailable, because download has not finished yet.");
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:localizedTitle
													message:localizedMessage
												   delegate:self
										  cancelButtonTitle:NSLocalizedString(@"OK", @"Generic OK")
										  otherButtonTitles:nil];
	[alert show];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
		
	if (self.indexPathToFocus != nil) {
		if (CGRectEqualToRect(self.collectionView.frame, CGRectZero) == NO) {
			[self.collectionView scrollToItemAtIndexPath:self.indexPathToFocus
										atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
												animated:NO];
            ((SKYFileViewerCollectionViewLayout *)self.collectionViewFlowLayout).currentPage = self.indexPathToFocus.row;
			
			// so it only happens once.
			self.indexPathToFocus = nil;
		}
	}
}

#pragma mark - UICollectionViewDelegate methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
	return collectionView.frame.size;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSArray *visibleIndexPaths = [self.collectionView indexPathsForVisibleItems];
    if (visibleIndexPaths.count > 0 && !self.scrollLocked) {
        NSIndexPath *indexPath = visibleIndexPaths.lastObject;
        [self.interactionDelegate userDidScrollToItemAtIndex:indexPath.row];
        [self updateFavouriteButtonItem];
    }
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return [self.dataSource numberOfItems];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	SKYFileViewerFileViewCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SKYFileViewerFileViewCollectionCellReuseIdentifier forIndexPath:indexPath];
	cell.interactionDelegate = self.interactionDelegate;
	[cell displayFileView:[self.dataSource fileViewForItemAtIndex:indexPath.row]];
	
	return cell;
}

@end

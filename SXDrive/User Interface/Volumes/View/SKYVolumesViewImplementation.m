//
//  SKYVolumesViewImplementation.m
//  SXDrive
//
//  Created by Skylable on 19/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYVolumesViewImplementation.h"

#import "SKYVolumesViewCollectionCell.h"
#import "UIColor+SKYColor.h"
#import "SKYInfoKeys.h"

/**
 * Height of volume cells.
 */
static CGFloat const SKYVolumesViewVolumeCellHeight = 105.f;

@interface SKYVolumesViewImplementation () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

/**
 * Collevion view's layout.
 */
@property (nonatomic, strong) UICollectionViewFlowLayout *collectionViewFlowLayout;

/**
 * Helper method to configure collection view cells.
 * @param cell      Cell to configure.
 * @param indexPath Index path of the cell.
 */
- (void)configureCell:(SKYVolumesViewCollectionCell *)cell forIndexPath:(NSIndexPath *)indexPath;

@end

@implementation SKYVolumesViewImplementation

@synthesize interactionDelegate = _interactionDelegate;
@synthesize dataSource = _dataSource;
@synthesize collectionView = _collectionView;

- (void)createSubviews
{
	self.backgroundColor = [UIColor whiteColor];
	
	self.collectionViewFlowLayout = [UICollectionViewFlowLayout new];
	self.collectionViewFlowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
	self.collectionViewFlowLayout.minimumInteritemSpacing = 0.f;
	self.collectionViewFlowLayout.minimumLineSpacing = 0.f;
	self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.collectionViewFlowLayout];
	self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.collectionView registerClass:[SKYVolumesViewCollectionCell class] forCellWithReuseIdentifier:SKYVolumesViewCollectionCellReuseIdentifier];
	self.collectionView.delegate = self;
	self.collectionView.dataSource = self;
	self.collectionView.backgroundColor = [UIColor whiteColor];
	self.collectionView.alwaysBounceVertical = YES;

	[self addSubview:self.collectionView];
	
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": self.collectionView}]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view": self.collectionView}]];
}

- (void)reloadData
{
	[self.collectionView reloadData];
}

#pragma mark - UICollectionViewDelegate methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
	return CGSizeMake((self.collectionView.frame.size.width) / 2.f, SKYVolumesViewVolumeCellHeight);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	[self.interactionDelegate userDidSelectVolumeAtIndex:indexPath.row];
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return [self.dataSource numberOfVolumes];
}

- (void)configureCell:(SKYVolumesViewCollectionCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
	cell.displayRightSeparator = row % 2 == 0;
	
	NSInteger numberOfItems = [self collectionView:self.collectionView numberOfItemsInSection:0];
	if (numberOfItems % 2 == 0) {
		cell.displayBottomSeparator = !(row >= numberOfItems - 2);
	}
	else {
		cell.displayBottomSeparator = !(row == numberOfItems - 1);
	}
    
    NSString *title = [self.dataSource titleForVolumeAtIndex:row];
    BOOL locked = [self.dataSource volumeWithTitleLocked:title];
    BOOL encrypted = [self.dataSource volumeAtIndexEncrypted:row];
    BOOL selectionEnabled = !locked || [[self.dataSource volumBrowserMode] isEqualToString:SKYBrowserModeDefault];
	[cell configureCellWithVolumeName:title
						   volumeSize:[self.dataSource sizeForVolumeAtIndex:row]
					   isVolumeLocked:locked
                    isVolumeEncrypted:encrypted
                     selectionEnabled:selectionEnabled];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	SKYVolumesViewCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SKYVolumesViewCollectionCellReuseIdentifier forIndexPath:indexPath];
	
	[self configureCell:cell forIndexPath:indexPath];
	
	return cell;
}

- (void)deselectSelectedVolumeCell
{
	NSArray *selectedIndexPaths = [self.collectionView indexPathsForSelectedItems];
	
	if (selectedIndexPaths.count > 0) {
		[self.collectionView deselectItemAtIndexPath:selectedIndexPaths[0] animated:YES];
	}
}

@end

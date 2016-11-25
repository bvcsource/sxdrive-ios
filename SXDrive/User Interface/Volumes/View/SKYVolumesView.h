//
//  SKYVolumesView.h
//  SXDrive
//
//  Created by Skylable on 19/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYBaseView.h"

@class SKYVolumesViewCollectionCell;

/**
 * Delegate for handling view events.
 */
@protocol SKYVolumesViewInteractionDelegate <NSObject>

/**
 * Called when user selects the volume.
 * @param index Index of selected volume.
 */
- (void)userDidSelectVolumeAtIndex:(NSInteger)index;

@end

/**
 * Data source for volumes view.
 */
@protocol SKYVolumesViewDataSource <NSObject>

/**
 * Returns number of volumes.
 * @return Number of volumes.
 */
- (NSInteger)numberOfVolumes;

/**
 * Returns title for volume at given index.
 * @param index Index.
 * @return Title.
 */
- (NSString *)titleForVolumeAtIndex:(NSInteger)index;

/**
 * Returns size for volume at given index.
 * @param index Index.
 * @return Size.
 */
- (NSString *)sizeForVolumeAtIndex:(NSInteger)index;

/**
 * Checks if a volume with specified title has read only access.
 * @param volume title.
 * @return boolean value indication if volume is locked.
 */
- (BOOL)volumeWithTitleLocked:(NSString *)volumeTitle;

/**
 * Checks if a volume at given index is encrypted.
 * @param  index Index.
 * @return boolean value indication if volume is encrypted.
 */
- (BOOL)volumeAtIndexEncrypted:(NSInteger)index;

/** 
 * Returns browser mode
 * @return browser mode: default or choose directory.
 */
- (NSString *)volumBrowserMode;

@end

/**
 * Protocol of volumes view.
 */
@protocol SKYVolumesView <SKYBaseView>

/**
 * The delegate for interaction events.
 */
@property (nonatomic, weak) id <SKYVolumesViewInteractionDelegate> interactionDelegate;

/**
 * Data source.
 */
@property (nonatomic, weak) id <SKYVolumesViewDataSource> dataSource;

/**
 * Collection View responsible for displaying volumes.
 */
@property (nonatomic, strong) UICollectionView *collectionView;

/**
 * Deselects selected volume cell.
 */
- (void)deselectSelectedVolumeCell;

/**
 * Reloads the data.
 */
- (void)reloadData;

@end

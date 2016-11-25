//
//  SKYVolumesViewCollectionCell.h
//  SXDrive
//
//  Created by Skylable on 21/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

@import UIKit;

/**
 * Reuse identifier for SKYVolumesViewCollectionCell.
 */
extern NSString * const SKYVolumesViewCollectionCellReuseIdentifier;

/**
 * Implementation of Volumes collection cell.
 */
@interface SKYVolumesViewCollectionCell : UICollectionViewCell

/**
 * When YES displays 1 point width separator on the right.
 */
@property (nonatomic) BOOL displayRightSeparator;

/**
 * When YES displays 1 point width separator on the bottom.
 */
@property (nonatomic) BOOL displayBottomSeparator;

/**
 * Configures the cell with provided values.
 * @param volumeName        Volume name to display.
 * @param volumeSize        Volume size to display.
 * @param isVolumeLocked    Locked param to use correct volume image.
 * @param isVolumeEncrypted Encrypted param to use correct volume image.
 * @param enabled           Defines if cell gets highlighted while selecting.
 */
- (void)configureCellWithVolumeName:(NSString *)volumeName
                         volumeSize:(NSString *)volumeSize
                     isVolumeLocked:(BOOL)isVolumeLocked
                  isVolumeEncrypted:(BOOL)isVolumeEncrypted
                   selectionEnabled:(BOOL)enabled;

@end

//
//  SKYFileViewerFileViewCollectionCell.h
//  SXDrive
//
//  Created by Skylable on 15/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

@import UIKit;

#import "SKYFileViewerViewImplementation.h"

/**
 * Reuse identifier for SKYFileViewerFileViewCollectionCell.
 */
extern NSString * const SKYFileViewerFileViewCollectionCellReuseIdentifier;

/**
 * Implementation of FileViewer collection cell.
 */
@interface SKYFileViewerFileViewCollectionCell : UICollectionViewCell

/**
 * Delegate for handling view events.
 * This is the same delegate as the presenting view use.
 */
@property (nonatomic, weak) id <SKYFileViewerViewInteractionDelegate> interactionDelegate;

/**
 * Displays the file preview within cell.
 * @param fileView FileView to present.
 */
- (void)displayFileView:(UIView *)fileView;

@end

//
//  SKYFileViewerCollectionView.h
//  SXDrive
//
//  Created by Skylable on 21/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import <UIKit/UIKit.h>

/**
 * String representation of `currentPage` property.
 */
extern NSString * const SKYFileViewerCollectionViewCurrentPagePropertyName;

/**
 * Subclass for Collection View used in File Viewer.
 */
@interface SKYFileViewerCollectionView : UICollectionView

/**
 * Current page displayed by collection view.
 */
@property (nonatomic, readonly) NSUInteger currentPage;

@end

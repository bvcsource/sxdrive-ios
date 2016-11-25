//
//  SKYSingleFileViewImageView.h
//  SXDrive
//
//  Created by Skylable on 05/11/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

@import Foundation;

/**
 * Subview presenting zoomable image.
 */
@interface SKYSingleFileViewImageView : UIScrollView

/**
 * Displays given image.
 * @param image Image to display.
 */
- (void)displayImage:(UIImage *)image;

@end

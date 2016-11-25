//
//  SKYBrowseDirectoryViewCell.h
//  SXDrive
//
//  Created by Skylable on 19/11/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

@import UIKit;

/**
 * Abstract class for other cells on SKYBrowseDirectoryView.
 */
@interface SKYBrowseDirectoryViewCell : UITableViewCell

/**
 * Helper method used to create subviews.
 */
- (void)createSubviews NS_REQUIRES_SUPER;

@end

//
//  SKYBrowseDirectoryViewFileCell.h
//  SXDrive
//
//  Created by Skylable on 17.09.2014.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYBrowseDirectoryViewCell.h"

@class SKYItem;

/**
 * Reuse identifier for SKYBrowseDirectoryViewFileCell.
 */
extern NSString * const SKYBrowseDirectoryViewFileCellReuseIdentifier;

/**
 * Class for file cell.
 */
@interface SKYBrowseDirectoryViewFileCell : SKYBrowseDirectoryViewCell

/**
 * Fills the cell.
 * @param fileName         Filename.
 * @param fileSize         File size.
 * @param modificationDate Modification date.
 * @param withStar         YES if star should be displayed, NO otherwise.
 * @param item             SKYItem (for download progress).
 */
- (void)fillWithFileName:(NSString *)fileName fileSize:(NSString *)fileSize modificationDate:(NSString *)modificationDate withStar:(BOOL)withStar item:(SKYItem *)item;

@end

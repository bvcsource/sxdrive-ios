//
//  SKYBrowseDirectoryViewDirectoryCell.h
//  SXDrive
//
//  Created by Skylable on 17.09.2014.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYBrowseDirectoryViewCell.h"

/**
 * Reuse identifier for SKYBrowseDirectoryViewDirectoryCell.
 */
extern NSString * const SKYBrowseDirectoryViewDirectoryCellReuseIdentifier;

/**
 * Class for directory cell.
 */
@interface SKYBrowseDirectoryViewDirectoryCell : SKYBrowseDirectoryViewCell

/**
 * Fill the directory name label.
 * @param directoryName Name of the directory.
 */
- (void)fillWithDirectoryName:(NSString *)directoryName;

@end

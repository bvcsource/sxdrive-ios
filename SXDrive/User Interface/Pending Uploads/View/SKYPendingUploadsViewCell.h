//
//  SKYPendingUploadsViewCell.h
//  SXDrive
//
//  Created by Skylable on 17/11/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

@import UIKit;

#import "SKYPendingUploadsView.h"

/**
 * Reuse identifier for SKYPendingUploadsViewCell.
 */
extern NSString * const SKYPendingUploadsViewBuiltInCellReuseIdentifier;
extern NSString * const SKYPendingUploadsViewSummaryCellReuseIdentifier;

/**
 * Class for pending uploads.
 */
@interface SKYPendingUploadsViewCell : UITableViewCell

/**
 * The delegate for interaction events.
 */
@property (nonatomic, weak) id <SKYPendingUploadsViewInteractionDelegate> interactionDelegate;

/**
 * Index path of this cell.
 */
@property (nonatomic, strong) NSIndexPath *indexPath;

/**
 * Fill the cell with data.
 * @param file      Name of the item.
 * @param details   Details of the item: path or file size and modification date.
 * @param progress  Upload progress.
 * @param iconImage Icon to display.
 */
- (void)fillWithName:(NSString *)name detailsText:(NSString *)details progress:(float)progress iconImage:(UIImage *)iconImage path:(NSString *)path;

@end

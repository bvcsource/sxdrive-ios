//
//  SKYSyncDeleteDirectoryAction.h
//  SXDrive
//
//  Created by Skylable on 14/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYSyncAction.h"

/**
 * Sync action resposible for deleting directory with all it's contents.
 * It uses SKYSyncDeleteFileAction to delete the files.
 */
@interface SKYSyncDeleteDirectoryAction : SKYSyncAction

/**
 * Creates delete directory action with given item.
 * @param item Item to delete.
 * @return Initialized SKYSyncDeleteDirectoryAction.
 */
+ (instancetype)actionWithItem:(SKYItem *)item;

@end

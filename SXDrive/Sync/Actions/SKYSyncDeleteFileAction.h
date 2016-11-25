//
//  SKYSyncDeleteFileAction.h
//  SXDrive
//
//  Created by Skylable on 05.10.2014.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYSyncAction.h"

/**
 * Sync action resposible for deleting file.
 */
@interface SKYSyncDeleteFileAction : SKYSyncAction

/**
 * Creates delete file action with given item.
 * @param item Item to delete.
 * @return Initialized SKYSyncDeleteFileAction.
 */
+ (instancetype)actionWithItem:(SKYItem *)item;

/**
 * Creates delete file action with given path.
 * @param path Path to delete
 * @return Initialized SKYSyncDeleteFileAction.
 */
+ (instancetype)actionWithPath:(NSString *)path;

@end

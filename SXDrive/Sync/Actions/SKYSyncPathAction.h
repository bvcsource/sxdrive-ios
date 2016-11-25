//
//  SKYSyncPathAction.h
//  SXDrive
//
//  Created by Skylable on 07.10.2014.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYSyncAction.h"

/**
 * Sync action resposible for keeping the given path in sync.
 */
@interface SKYSyncPathAction : SKYSyncAction

/**
 * Creates sync path action with given item.
 * @param item Item (directory) to sync.
 * @return Initialized SKYSyncPathAction.
 */
+ (instancetype)actionWithItem:(SKYItem *)item;

@end

//
//  SKYSyncCreateDirectoryAction.h
//  SXDrive
//
//  Created by Skylable on 03.10.2014.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYSyncAction.h"

/**
 * Action responsible for creating the directory in the Cloud based on client input.
 */
@interface SKYSyncCreateDirectoryAction : SKYSyncAction

/**
 * Creates create directory action with given item.
 * @param item Item (directory) to create..
 * @return Initialized SKYSyncCreateDirectoryAction.
 */
+ (instancetype)actionWithItem:(SKYItem *)item;

@end

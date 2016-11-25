//
//  SKYSyncUploadFileAction.h
//  SXDrive
//
//  Created by Skylable on 05.10.2014.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYSyncAction.h"

/**
 * Sync action resposible for uploading file.
 */
@interface SKYSyncUploadFileAction : SKYSyncAction

/**
 * Creates upload file action with given item.
 * @param item Item to upload.
 * @return Initialized SKYSyncUploadFileAction.
 */
+ (instancetype)actionWithItem:(SKYItem *)item;

@end

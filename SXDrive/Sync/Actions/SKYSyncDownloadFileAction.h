//
//  SKYSyncDownloadFileAction.h
//  SXDrive
//
//  Created by Skylable on 10.10.2014.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYSyncAction.h"

/**
 * Sync action resposible for downloading file.
 */
@interface SKYSyncDownloadFileAction : SKYSyncAction

/**
 * Creates download file action with given item.
 * @param item Item to download.
 * @return Initialized SKYSyncDownloadFileAction.
 */
+ (instancetype)actionWithItem:(SKYItem *)item;

@end

/**
 * SKYSyncDownloadFileAction but for favourite files.
 * @note Doesn't do anything special, only naming issue.
 */
@interface SKYSyncFavouriteDownloadFileAction : SKYSyncDownloadFileAction

@end

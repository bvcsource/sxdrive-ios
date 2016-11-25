//
//  SKYSingleFileBehaviour.h
//  SXDrive
//
//  Created by Skylable on 15/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

@import Foundation;

#import "SKYBaseBehaviour.h"
#import "SKYPersistence.h"
#import "SKYSyncService.h"

/**
 * Presenter for the single file behaviour.
 */
@protocol SKYSingleFileBehaviourPresenter <SKYBaseBehaviourPresenter>

/**
 * Instructs the presenter to display before view (icon, progress bar etc) for given item.
 * @param item Item.
 */
- (void)displayBeforeViewForItem:(SKYItem *)item;

/**
 * Instructs the presenter to display progress.
 *
 * @param progress Progress.
 */
- (void)displayProgress:(float)progress;

/**
 * Instructs the presenter to display the file (if the file can be displayed).
 *
 * @param path Path to the file.
 */
- (void)displayFileContentsAtPath:(NSString *)path;

@end

/**
 * Protocol of single file behaviour.
 */
@protocol SKYSingleFileBehaviour <SKYBaseBehaviour>

/**
 * Presenter for the single file behaviour.
 */
@property (nonatomic, weak) id <SKYSingleFileBehaviourPresenter> presenter;

/**
 * Persistence.
 */
@property (nonatomic, strong) id <SKYPersistence> persistence;

/**
 * Sync service.
 */
@property (nonatomic, strong) id <SKYSyncService> syncService;

@end

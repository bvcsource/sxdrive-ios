//
//  SKYVolumesBehaviour.h
//  SXDrive
//
//  Created by Skylable on 19/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

@import Foundation;

#import "SKYBaseBehaviour.h"
#import "SKYPersistence.h"
#import "SKYSyncService.h"

/**
 * Presenter for the volumes behaviour.
 */
@protocol SKYVolumesBehaviourPresenter <SKYBaseBehaviourPresenter>

/**
 * Browser mode: default or choose directory.
 */
@property (nonatomic, strong) NSString *browserMode;

/**
 * Instructs the presenter to display volumes based on fetched results controller.
 * @param fetchedResultsController Fetched results controller configured to provide the volumes.
 */
- (void)displayVolumesFromFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController;

/**
 * Shows 'Choose Directory' button in case of a respective browser mode.
 */
- (void)displayToolsForChoosingDirectory;

@end

/**
 * Protocol of volumes behaviour.
 */
@protocol SKYVolumesBehaviour <SKYBaseBehaviour>

/**
 * Presenter for the volumes behaviour.
 */
@property (nonatomic, weak) id <SKYVolumesBehaviourPresenter> presenter;

/**
 * Persistence.
 */
@property (nonatomic, strong) id <SKYPersistence> persistence;

/**
 * Sync service.
 */
@property (nonatomic, strong) id <SKYSyncService> syncService;

/**
 * Method called when user selected an volume.
 * @param item Selected volume.
 */
- (void)userDidSelectVolume:(SKYItem *)item;

/**
 * Starts keeping the volumes in sync.
 */
- (void)startKeepingVolumesInSync;

/**
 * Stops keeping the volumes in sync.
 */
- (void)stopKeepingVolumesInSync;

/**
 * Called when user presses cancel button in navigation while choosing directory.
 */
- (void)userDidCancelChoosingDirectory;

@end

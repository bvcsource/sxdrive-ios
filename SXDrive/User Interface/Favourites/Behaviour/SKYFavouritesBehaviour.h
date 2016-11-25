//
//  SKYFavouritesBehaviour.h
//  SXDrive
//
//  Created by Skylable on 19/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

@import CoreData;
@import Foundation;

#import "SKYBaseBehaviour.h"
#import "SKYPersistence.h"
#import "SKYUser.h"

/**
 * Presenter for the favourites behaviour.
 */
@protocol SKYFavouritesBehaviourPresenter <SKYBaseBehaviourPresenter>

/**
 * Instructs the presenter to display results based on fetched results controller.
 * @param fetchedResultsController Fetched results controller configured to provide favourites.
 */
- (void)displayFavouritesFromFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController;

@end

/**
 * Protocol of favourites behaviour.
 */
@protocol SKYFavouritesBehaviour <SKYBaseBehaviour>

/**
 * Presenter for the favourites behaviour.
 */
@property (nonatomic, weak) id <SKYFavouritesBehaviourPresenter> presenter;

/**
 * User.
 */
@property (nonatomic, strong) id <SKYUser> user;

/**
 * Persistence.
 */
@property (nonatomic, strong) id <SKYPersistence> persistence;

/**
 * Method called when user selected an item.
 * @param item Selected item.
 */
- (void)userDidSelectItem:(SKYItem *)item;

/**
 * Shows file revisions.
 * @param item Item to show revisions.
 */
- (void)showRevisionsForItem:(SKYItem *)item;

@end

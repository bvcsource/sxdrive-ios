//
//  SKYFavouritesController.h
//  SXDrive
//
//  Created by Skylable on 19/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYBaseController.h"
#import "SKYFavouritesBehaviour.h"
#import "SKYBrowseDirectoryView.h"

/**
 * View controller for favourites.
 */
@interface SKYFavouritesController : SKYBaseControllerImplementation <SKYFavouritesBehaviourPresenter, SKYBrowseDirectoryViewInteractionDelegate, SKYBrowseDirectoryViewDataSource>

/**
 * Creates an instance of favourites controller.
 * @param browseDirectoryView Browse directory view to use.
 * @param favouritesBehaviour Browse directory behaviour to use.
 * @return An instance of favourites controller.
 */
- (instancetype)initWithBrowseDirectoryView:(UIView <SKYBrowseDirectoryView> *)browseDirectoryView favouritesBehaviour:(id <SKYFavouritesBehaviour>)favouritesBehaviour;

@end

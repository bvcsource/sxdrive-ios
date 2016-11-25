//
//  SKYBrowseDirectoryController.h
//  SXDrive
//
//  Created by Skylable on 17/09/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYBaseController.h"
#import "SKYBrowseDirectoryBehaviour.h"
#import "SKYBrowseDirectoryView.h"

/**
 * View controller for browse directory.
 */
@interface SKYBrowseDirectoryController : SKYBaseTableControllerImplementation <SKYBrowseDirectoryBehaviourPresenter, SKYBrowseDirectoryViewInteractionDelegate, SKYBrowseDirectoryViewDataSource>

/**
* Creates an instance of browse directory controller.
*
* @param browseDirectoryView      Browse directory view to use.
* @param browseDirectoryBehaviour Browse directory behaviour to use.
*
* @return An instance of browse directory controller.
*/
- (instancetype)initWithBrowseDirectoryView:(UITableView <SKYBrowseDirectoryView> *)browseDirectoryView browseDirectoryBehaviour:(id <SKYBrowseDirectoryBehaviour>)browseDirectoryBehaviour;

@end

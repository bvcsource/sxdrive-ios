//
//  SKYPendingUploadsController.h
//  SXDrive
//
//  Created by Skylable on 16/11/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYBaseController.h"
#import "SKYPendingUploadsBehaviour.h"
#import "SKYPendingUploadsView.h"

/**
 * View controller for pending uploads.
 */
@interface SKYPendingUploadsController : SKYBaseTableControllerImplementation <SKYPendingUploadsBehaviourPresenter, SKYPendingUploadsViewInteractionDelegate, SKYPendingUploadsViewDataSource>

/**
 * Creates an instance of pending uploads controller.
 *
 * @param pendingUploadsView      Browse directory view to use.
 * @param pendingUploadsBehaviour Browse directory behaviour to use.
 *
 * @return An instance of browse directory controller.
 */
- (instancetype)initWithPendingUploadsView:(UITableView <SKYPendingUploadsView> *)pendingUploadsView pendingUploadsBehaviour:(id <SKYPendingUploadsBehaviour>)pendingUploadsBehaviour;

@end

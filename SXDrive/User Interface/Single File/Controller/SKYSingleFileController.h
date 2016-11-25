//
//  SKYSingleFileController.h
//  SXDrive
//
//  Created by Skylable on 15/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYBaseController.h"
#import "SKYSingleFileBehaviour.h"
#import "SKYSingleFileView.h"

/**
 * View controller for single file.
 */
@interface SKYSingleFileController : SKYBaseControllerImplementation <SKYSingleFileBehaviourPresenter, SKYSingleFileViewInteractionDelegate>

/**
 * Creates an instance of single file controller.
 * @param singleFileView      Single file view to use.
 * @param singleFileBehaviour Single file behaviour to use.
 * @return An instance of single file controller.
 */
- (instancetype)initWithSingleFileView:(UIView <SKYSingleFileView> *)singleFileView singleFileBehaviour:(id <SKYSingleFileBehaviour>)singleFileBehaviour;

@end

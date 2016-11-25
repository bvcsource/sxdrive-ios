//
//  SKYFileViewerController.h
//  SXDrive
//
//  Created by Skylable on 19.09.2014.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYBaseController.h"
#import "SKYFileViewerBehaviour.h"
#import "SKYFileViewerView.h"

/**
 * View controller for file viewer.
 */
@interface SKYFileViewerController : SKYBaseControllerImplementation <SKYFileViewerBehaviourPresenter, SKYFileViewerViewInteractionDelegate, SKYFileViewerViewDataSource>

/**
 * Creates an instance of file viewer controller.
 * @param fileViewerView      Browse directory view to use.
 * @param fileViewerBehaviour Browse directory behaviour to use.
 * @return An instance of file viewer controller.
 */
- (instancetype)initWithFileViewerView:(UIView <SKYFileViewerView> *)fileViewerView fileViewerBehaviour:(id <SKYFileViewerBehaviour>)fileViewerBehaviour;

@end

//
//  SKYVolumesController.h
//  SXDrive
//
//  Created by Skylable on 19/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYBaseController.h"
#import "SKYVolumesBehaviour.h"
#import "SKYVolumesView.h"

/**
 * View controller for volumes.
 */
@interface SKYVolumesController : SKYBaseControllerImplementation <SKYVolumesBehaviourPresenter, SKYVolumesViewInteractionDelegate, SKYVolumesViewDataSource>

/**
 * Creates an instance of volumes controller.
 * @param volumesView      Volumes view to use.
 * @param volumesBehaviour Volumes behaviour to use.
 * @return An instance of volumes controller.
 */
- (instancetype)initWithVolumesView:(UIView <SKYVolumesView> *)volumesView volumesBehaviour:(id <SKYVolumesBehaviour>)volumesBehaviour;

@end

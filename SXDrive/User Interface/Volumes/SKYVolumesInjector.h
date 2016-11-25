//
//  SKYVolumesInjector.h
//  SXDrive
//
//  Created by Skylable on 19/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYBaseController.h"
#import "SKYViewNavigator.h"

/**
 * Injector for volumes section.
 */
@interface SKYVolumesInjector : NSObject

/**
 * Injects a ready to use volumes controller.
 * @param viewNavigator View navigator to use.
 * @return An instance of volumes controller.
 */
+ (id <SKYBaseController>)injectViewControllerWithViewNavigator:(id <SKYViewNavigator>)viewNavigator;

@end

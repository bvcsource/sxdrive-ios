//
//  SKYFileViewerInjector.h
//  SXDrive
//
//  Created by Skylable on 19.09.2014.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYBaseController.h"

/**
 * Injector for file viewer section.
 */
@interface SKYFileViewerInjector : NSObject

/**
 * Injects a ready to use file viewer controller.
 * @param viewNavigator View navigator to use.
 * @return An instance of file viewer controller.
 */
+ (id <SKYBaseController>)injectViewControllerWithViewNavigator:(id <SKYViewNavigator>)viewNavigator;

@end

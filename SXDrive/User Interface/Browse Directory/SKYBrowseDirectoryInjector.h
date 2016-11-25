//
//  SKYBrowseDirectoryInjector.h
//  SXDrive
//
//  Created by Skylable on 17/09/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYBaseController.h"
#import "SKYViewNavigator.h"

/**
 * Injector for browse directory section.
 */
@interface SKYBrowseDirectoryInjector : NSObject

/**
 * Injects a ready to use browse directory controller.
 * @param viewNavigator View navigator to use.
 * @return An instance of browse directory controller.
 */

+ (id <SKYBaseController>)injectViewControllerWithViewNavigator:(id <SKYViewNavigator>)viewNavigator;

@end

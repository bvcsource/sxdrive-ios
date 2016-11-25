//
//  SKYSingleFileInjector.h
//  SXDrive
//
//  Created by Skylable on 15/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYBaseController.h"
#import "SKYViewNavigator.h"

@class SKYItem;

/**
 * Injector for single file section.
 */
@interface SKYSingleFileInjector : NSObject

/**
 * Injects a ready to use single file controller.
 * @param item Item to control.
 * @return An instance of single file controller.
 */
+ (id <SKYBaseController>)injectViewControllerWithItem:(SKYItem *)item;

@end

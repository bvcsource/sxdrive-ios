//
//  SKYPasscodeInjector.h
//  SXDrive
//
//  Created by Skylable on 01/11/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYBaseController.h"
#import "SKYViewNavigator.h"

/**
 * Injector for passcode section.
 */
@interface SKYPasscodeInjector : NSObject

/**
 * Injects a ready to use passcode controller.
 * @param viewNavigator View navigator to use.
 * @return An instance of passcode controller.
 */
+ (id <SKYBaseController>)injectViewControllerWithViewNavigator:(id <SKYViewNavigator>)viewNavigator;

@end

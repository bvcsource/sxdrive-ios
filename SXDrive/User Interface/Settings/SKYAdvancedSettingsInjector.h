//
//  SKYAdvancedSettingsInjector.h
//  SXDrive
//
//  Created by Skylable on 5/19/15.
//  Copyright (c) 2015 Skylable. All rights reserved.
//

#import "SKYBaseController.h"
#import "SKYViewNavigator.h"

/**
 * Injector for advanced settings section.
 */
@interface SKYAdvancedSettingsInjector : NSObject

/**
 * Injects a ready to use advanced settings controller.
 * @param viewNavigator View navigator to use.
 * @return An instance of advanced settings controller.
 */
+ (id <SKYBaseController>)injectViewControllerWithViewNavigator:(id <SKYViewNavigator>)viewNavigator;

@end

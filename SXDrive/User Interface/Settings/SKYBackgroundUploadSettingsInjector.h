//
//  SKYBackgroundUploadSettingsInjector.h
//  SXDrive
//
//  Created by Skylable on 7/29/15.
//  Copyright (c) 2015 Skylable. All rights reserved.
//

#import "SKYBaseController.h"
#import "SKYViewNavigator.h"

/**
 * Injector for background upload settings section.
 */
@interface SKYBackgroundUploadSettingsInjector : NSObject

/**
 * Injects a ready to use background upload settings controller.
 * @param viewNavigator View navigator to use.
 * @return An instance of background upload settings controller.
 */
+ (id <SKYBaseController>)injectViewControllerWithViewNavigator:(id <SKYViewNavigator>)viewNavigator;

@end

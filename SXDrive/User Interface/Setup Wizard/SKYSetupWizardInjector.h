//
//  SKYSetupWizardInjector.h
//  SXDrive
//
//  Created by Skylable on 4/20/15.
//  Copyright (c) 2015 Skylable. All rights reserved.
//

#import "SKYBaseController.h"
#import "SKYViewNavigator.h"

/**
 * Injector for setup wizard section.
 */
@interface SKYSetupWizardInjector : NSObject

/**
 * Injects a ready to use setup wizard controller.
 * @param viewNavigator View navigator to use.
 * @return An instance of setup wizard controller.
 */
+ (id <SKYBaseController>)injectViewControllerWithViewNavigator:(id <SKYViewNavigator>)viewNavigator;

@end

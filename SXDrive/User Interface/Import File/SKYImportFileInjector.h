//
//  SKYImportFileInjector.h
//  SXDrive
//
//  Created by Skylable on 5/6/15.
//  Copyright (c) 2015 Skylable. All rights reserved.
//

#import "SKYBaseController.h"
#import "SKYViewNavigator.h"

/**
 * Injector for import file section.
 */
@interface SKYImportFileInjector : NSObject

/**
 * Injects a ready to use import file controller.
 * @param viewNavigator View navigator to use.
 * @return An instance of import file controller.
 */
+ (id <SKYBaseController>)injectViewControllerWithViewNavigator:(id <SKYViewNavigator>)viewNavigator;

@end

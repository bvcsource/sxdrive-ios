//
//  SKYViewNavigator.h
//  SXDrive
//
//  Created by Skylable on 18/09/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

@import Foundation;
@import UIKit;

@class SKYNavigationController;

@protocol SKYBaseController;

#import "SKYViewType.h"

/**
 * Protocol of the view navigator.
 */
@protocol SKYViewNavigator <NSObject>

/**
 * Displays the root view controller of the application.
 */
- (void)displayApplicationRootController;

/**
 * Navigates from given view controller to the one associated with given type.
 * @param fromVC   From view controller.
 * @param viewType View type of the new view view.
 */
- (void)navigateFromViewController:(UIViewController *)fromVC toViewWithType:(SKYViewType)viewType;

/**
 * Navigates from given view controller to the one associated with given type.
 * @param fromVC   From view controller.
 * @param viewType View type of the new view view.
 * @param info     Info passed to the view.
 */
- (void)navigateFromViewController:(UIViewController *)fromVC toViewWithType:(SKYViewType)viewType info:(NSDictionary *)info;

/**
 * Closes the view controller by either popping the view or dismissing it.
 * @param vcToClose View controller to close.
 */
- (void)closeViewController:(UIViewController *)vcToClose;

/**
 * Returns to previous controller in the navigation stack.
 * @param fromVC   From view controller.
 * @param viewType View type of the view to return to.
 */
- (void)returnFromViewController:(UIViewController *)fromVC toViewWithType:(SKYViewType)viewType;

/**
 * Sends user to specified directory and starts to import file.
 * @param items    An array of SKYItem objects.
 * @param file     Dictionary that contains file info.
 */
- (void)navigateToDirectory:(NSArray *)items andAddFile:(NSDictionary *)file;

/**
 * Displays import file view controller, which allows user to add file to SXDrive.
 * @param animated  Present with animation.
 */
- (void)displayImportFileInterfaceAnimated:(BOOL)animated;

/**
 * Navigates to a specific directory from import file controller.
 * @param fromVC   From view controller.
 * @param items    An array of SKYItem objects.
 */
- (void)navigateFromImportFileController:(UIViewController *)fromVC toDirectory:(NSArray *)items;

/**
 * Navigates to volumes controller from background uploads settings controller.
 * @param fromVC   From view controller.
 */
- (void)navigateFromBackgroundUploadSettingsControllerToVolumesController:(UIViewController *)fromVC;

@end

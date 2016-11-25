//
//  SKYSettingsController.h
//  SXDrive
//
//  Created by Skylable on 12/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYBaseController.h"
#import "SKYSettingsBehaviour.h"
#import "SKYSettingsView.h"

/**
 * View controller for settings.
 */
@interface SKYSettingsController : SKYBaseTableControllerImplementation <SKYSettingsBehaviourPresenter, SKYSettingsViewInteractionDelegate, SKYSettingsViewDataSource>

/**
* Creates an instance of settings controller.
*
* @param settingsView      Settings view to use.
* @param settingsBehaviour Settings behaviour to use.
*
* @return An instance of settings controller.
*/
- (instancetype)initWithSettingsView:(UITableView <SKYSettingsView> *)settingsView settingsBehaviour:(id <SKYSettingsBehaviour>)settingsBehaviour;

@end

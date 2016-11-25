//
//  SKYBackgroundUploadSettingsController.h
//  SXDrive
//
//  Created by Skylable on 7/29/15.
//  Copyright (c) 2015 Skylable. All rights reserved.
//

#import "SKYBaseController.h"
#import "SKYSettingsBehaviour.h"
#import "SKYItem.h"
#import "SKYItem+Extras.h"

@interface SKYBackgroundUploadSettingsController : SKYBaseNibTableControllerImplementation <SKYSettingsBehaviourPresenter>

/**
 * Called when user presses choose directory button in navigation bar.
 */
- (void)userDidChooseDirectory:(SKYItem *)item;

/**
 * Called when user presses cancel button in toolbar while choosing directory.
 */
- (void)userDidCancelChoosingDirectory;

@end

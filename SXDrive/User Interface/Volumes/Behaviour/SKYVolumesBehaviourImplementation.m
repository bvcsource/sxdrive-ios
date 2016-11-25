//
//  SKYVolumesBehaviourImplementation.m
//  SXDrive
//
//  Created by Skylable on 19/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYVolumesBehaviourImplementation.h"

#import "SKYInfoKeys.h"
#import "SKYItem.h"
#import "SKYImportFileBehaviour.h"
#import "SKYBackgroundUploadSettingsController.h"

@interface SKYVolumesBehaviourImplementation ()

/*
 * Keeps reference to import file controller in case of choose directory browser mode.
 */
@property (nonatomic, assign) id<SKYImportFileBehaviourPresenter> importFileController;

/*
 * Keeps reference to background upload settings controller in case of choose directory browser mode.
 */
@property (nonatomic, assign) SKYBackgroundUploadSettingsController *backgroundUploadSettingsController;

@end

@implementation SKYVolumesBehaviourImplementation

@synthesize persistence = _persistence;
@synthesize syncService = _syncService;

- (void)processInfo:(NSDictionary *)info
{
    NSString *browserMode = info[SKYInfoKeyForBrowserMode];
    self.presenter.browserMode = browserMode != nil ? browserMode:SKYBrowserModeDefault;
    
	NSFetchedResultsController *frc = [self.persistence fetchedResultsControllerForVolumes];
	[self.presenter displayVolumesFromFetchedResultsController:frc];
    
    if ([self.presenter.browserMode isEqualToString:SKYBrowserModeChooseDirectory]) {
        self.importFileController = info[SKYInfoKeyForImpoerFileControllerReference];
        self.backgroundUploadSettingsController = info[SKYInfoKeyForBackgroundUploadSettingsControllerReference];
        [self.presenter displayToolsForChoosingDirectory];
    }
}

- (void)startKeepingVolumesInSync
{
	[self.syncService addItemToKeepInSync:nil];
}

- (void)stopKeepingVolumesInSync
{
	[self.syncService removeItemFromKeepInSync:nil];
}

- (void)userDidSelectVolume:(SKYItem *)item
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:item, SKYInfoKeyForItem, self.presenter.browserMode, SKYInfoKeyForBrowserMode, nil];
    if ([self.presenter.browserMode isEqualToString:SKYBrowserModeChooseDirectory]) {
        if (self.importFileController) {
            [dictionary setObject:self.importFileController forKey:SKYInfoKeyForImpoerFileControllerReference];
        }
        if (self.backgroundUploadSettingsController) {
            [dictionary setObject:self.backgroundUploadSettingsController forKey:SKYInfoKeyForBackgroundUploadSettingsControllerReference];
        }
    }
	[self.viewNavigator navigateFromViewController:[self.presenter viewControler]
									toViewWithType:SKYViewTypeBrowseDirectory
                                              info:[NSDictionary dictionaryWithDictionary:dictionary]
	 ];
}

- (void)userDidCancelChoosingDirectory {
    if (self.importFileController) {
        [[self.presenter viewControler].navigationController popToRootViewControllerAnimated:YES];
    }
    if (self.backgroundUploadSettingsController) {
        [self.backgroundUploadSettingsController userDidCancelChoosingDirectory];
        [[self.presenter viewControler] dismissViewControllerAnimated:YES completion:^{}];
    }
}

@end

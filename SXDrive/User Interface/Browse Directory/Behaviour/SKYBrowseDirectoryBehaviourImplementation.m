//
//  SKYBrowseDirectoryBehaviourImplementation.m
//  SXDrive
//
//  Created by Skylable on 17/09/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYBrowseDirectoryBehaviourImplementation.h"
#import <SSKeychain/SSKeychain.h>

#import "NSDateFormatter+Extras.h"
#import "SKYConfig.h"
#import "SKYInfoKeys.h"
#import "SKYItem+Extras.h"
#import "SKYPendingUploadsInjector.h"
#import "SKYPersistenceImplementation.h"
#import "SKYViewType.h"
#import "SKYImportFileBehaviour.h"
#import "SKYUser.h"
#import "SKYUserImplementation.h"
#import "NSString+Extras.h"
#import "UIDevice+ScreenSize.h"
#import "SKYBackgroundUploadSettingsController.h"

@interface SKYBrowseDirectoryBehaviourImplementation () <NSFetchedResultsControllerDelegate>

/**
 * Item that this behaviour browse.
 */
@property (nonatomic, strong) SKYItem *item;

/**
 * Volume name extracted from path.
 */
@property (nonatomic, strong) NSString *volumeName;

/**
 * Current item frc, to observe properties.
 */
@property (nonatomic, strong) NSFetchedResultsController *itemFRC;

/**
 * Keeps track if preview was shown, if YES later will be used to check if cache is above max cache.
 */
@property (nonatomic) BOOL previewWasShown;

/*
 * Keeps reference to import file controller in case of choose directory browser mode.
 */
@property (nonatomic, assign) id<SKYImportFileBehaviourPresenter> importFileController;

/*
 * Keeps reference to background upload settings controller in case of choose directory browser mode.
 */
@property (nonatomic, assign) SKYBackgroundUploadSettingsController *backgroundUploadSettingsController;

/**
 * Checks the current state of directory sync.
 */
- (void)analyzeSyncState;

@end

@implementation SKYBrowseDirectoryBehaviourImplementation

@synthesize persistence = _persistence;
@synthesize syncService = _syncService;
@synthesize networkManager = _networkManager;
@synthesize diskManager = _diskManager;
@synthesize user = _user;

- (void)processInfo:(NSDictionary *)info
{
    NSString *browserMode = info[SKYInfoKeyForBrowserMode];
    self.presenter.browserMode = browserMode != nil ? browserMode:SKYBrowserModeDefault;
    
	self.item = info[SKYInfoKeyForItem];
	self.volumeName = self.item.volumeName;
    
    if (info[SKYInfoKeyForImportFile]) {
        [self addFile:info[SKYInfoKeyForImportFile]];
    }
	
	self.itemFRC = [self.persistence fetchedResultsControllerForItem:self.item];
	self.itemFRC.delegate = self;
	[self.itemFRC performFetch:NULL];
	[self analyzeSyncState];
	
    if ([self.persistence canModifyVolumeWithName:self.volumeName]) {
        if ([self.presenter.browserMode isEqualToString:SKYBrowserModeChooseDirectory]) {
            self.importFileController = info[SKYInfoKeyForImpoerFileControllerReference];
            self.backgroundUploadSettingsController = info[SKYInfoKeyForBackgroundUploadSettingsControllerReference];
            [self.presenter displayToolsForChoosingDirectory];
        } else {
            [self.presenter displayToolsForUserWithWriteAccessRight];
        }
    }
    
    [self.presenter setDirectoryTitle:self.item.name];
	
	SKYPendingUploadsController *pendingUploadsController = (SKYPendingUploadsController *)[SKYPendingUploadsInjector injectViewControllerWithItem:self.item];
	[self.presenter displayPendingUploadsController:pendingUploadsController];
}

- (void)startKeepingDirectoryInSync
{
	[self.syncService addItemToKeepInSync:self.item];
	
	if (self.previewWasShown == YES) {
		[self.diskManager removeCacheAboveLimit];
	}
}

- (void)stopKeepingDirectoryInSync
{
	[self.syncService removeItemFromKeepInSync:self.item];
}

- (void)refresh
{
	[self.syncService syncItem:self.item favourites:NO];
}

- (void)createDirectoryWithName:(NSString *)name
{
	name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	if (name.length > 0) {
		name = [name stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
		name = [name stringByReplacingOccurrencesOfString:@"\\" withString:@"_"];
		name = [name stringByReplacingOccurrencesOfString:@"?" withString:@"_"];
		name = [name stringByReplacingOccurrencesOfString:@"%" withString:@"_"];
		name = [name stringByReplacingOccurrencesOfString:@"*" withString:@"_"];
		name = [name stringByReplacingOccurrencesOfString:@":" withString:@"_"];
		name = [name stringByReplacingOccurrencesOfString:@"|" withString:@"_"];
		name = [name stringByReplacingOccurrencesOfString:@"\"" withString:@"_"];
		name = [name stringByReplacingOccurrencesOfString:@"<" withString:@"_"];
		name = [name stringByReplacingOccurrencesOfString:@">" withString:@"_"];

		NSString *newDirectoryPath = [self.item.fullPath stringByAppendingPathComponent:name];
		[self.persistence addDirectoryAtPath:newDirectoryPath];
	}
}

- (void)addFile:(NSDictionary *)file
{
    NSDate *date = file[SKYInfoKeyForAssetDate];
    if (!date) {
        date = [NSDate date];
    }
	NSString *dateString = [[NSDateFormatter dateFormatterForMediaNames] stringFromDate:date];
	if (file[SKYInfoKeyForFileURL] != nil) {
		NSURL *fileSourceURL = file[SKYInfoKeyForFileURL];
        NSString *fileName = file[SKYInfoKeyForFileName];
        if (!fileName) {
            fileName = [[fileSourceURL path] lastPathComponent];
        }
		
		NSString *newFilePath = [self.item.fullPath stringByAppendingPathComponent:fileName];
		[self.persistence addFileAtPath:newFilePath
								content:fileSourceURL];
	}
	else if (file[SKYInfoKeyForImage] != nil && file[SKYInfoKeyForImageType] != nil) {
		NSString *extension = file[SKYInfoKeyForImageType];
		NSString *filename = [SKYConstantPhotoFilename stringByAppendingFormat:@"_%@.%@", dateString, extension];
		
		NSData *imageData = nil;
		if ([@[@"jpg", @"jpeg"] containsObject:extension.lowercaseString]) {
			imageData = UIImageJPEGRepresentation(file[SKYInfoKeyForImage], 1.f);
		}
		else {
			imageData = UIImagePNGRepresentation(file[SKYInfoKeyForImage]);
		}
		
		if (imageData != nil) {
			NSString *newFilePath = [self.item.fullPath stringByAppendingPathComponent:filename];
			[self.persistence addFileAtPath:newFilePath
									content:imageData];
		}
	}
	else if (file[SKYInfoKeyForMovieURL] != nil) {
		// TODO extension to check
		NSString *filename = [SKYConstantMovieFilename stringByAppendingFormat:@"_%@.%@", dateString, @"MOV"];

		NSString *newFilePath = [self.item.fullPath stringByAppendingPathComponent:filename];
		[self.persistence addFileAtPath:newFilePath
								content:file[SKYInfoKeyForMovieURL]];
	}
}

- (void)userDidSelectItem:(SKYItem *)item
{
	if (item.isDirectory.boolValue == YES) {
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
	else if ([self.presenter.browserMode isEqualToString:SKYBrowserModeDefault]) {
		NSDictionary *info = @{
							   SKYInfoKeyForItem: item,
							   SKYInfoKeyForItemDirectory: self.item,
							   SKYInfoKeyShowFavourites: @NO
							   };
		
		[self.viewNavigator navigateFromViewController:[self.presenter viewControler]
										toViewWithType:SKYViewTypeFileViewer
												  info:info
		 ];
		self.previewWasShown = YES;
	}
}

- (void)deleteItems:(NSArray *)items {
    for (SKYItem *item in items) {
        [self.persistence removeItem:item];
    }
}

- (void)analyzeSyncState
{
	if ([self.item hasProperty:SKYPropertyNameEverSynced] == YES) {
		NSFetchedResultsController *frc = [self.persistence fetchedResultsControllerForDirectory:self.item includeDirectories:YES];
		[self.presenter displayDirectoryListingFromFetchedResultsController:frc];
		
		if ([[self.item propertyValueForName:SKYPropertyNameLoading] boolValue] == YES) {
			[self.presenter displayLoadingIndicator:YES];
		}
		else {
			[self.presenter displayLoadingIndicator:NO];
		}
	}
	else {
		if ([self.networkManager hasInternetAccess] == NO) {
			[self.presenter displayNoInternetInterface];
		}
		else {
			[self.presenter displayLoadingInterface];
		}
	}
}

- (void)updateDirectory {
    if (self.importFileController) {
        [self.importFileController updateImportFileDirectory:self.item];
    }
    if (self.backgroundUploadSettingsController) {
    }
}

- (void)userDidChooseDirectory {
    if (self.importFileController) {
        [self.importFileController userDidChooseDirectory];
        [[self.presenter viewControler].navigationController popToRootViewControllerAnimated:YES];
    }
    if (self.backgroundUploadSettingsController) {
        [self.backgroundUploadSettingsController userDidChooseDirectory:self.item];
        [[self.presenter viewControler] dismissViewControllerAnimated:YES completion:^{}];
    }
}

- (void)userDidCancelChoosingDirectory {
    if (self.importFileController) {
        [self.importFileController userDidCancelChoosingDirectory];
        [[self.presenter viewControler].navigationController popToRootViewControllerAnimated:YES];
    }
    if (self.backgroundUploadSettingsController) {
        [self.backgroundUploadSettingsController userDidCancelChoosingDirectory];
        [[self.presenter viewControler] dismissViewControllerAnimated:YES completion:^{}];
    }
}

- (void)showRevisionsForItem:(SKYItem *)item {
    NSURL *url;
    NSString *sxWeb = [SSKeychain passwordForService:SKYUserKeychainSXDriveService
                                                        account:SKYUserKeychainSXWebAccount];
    if(sxWeb)
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/revs/%@/%@", sxWeb, item.volumeName, [item.name stringByEscapingPath]]];
    else
        url = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.%@/revs/%@/%@", self.user.hostURL, item.volumeName, [item.name stringByEscapingPath]]];

    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
	if (type == NSFetchedResultsChangeUpdate) {
		[self analyzeSyncState];
	}
}

- (void)changeSortingType:(SKYConfigSortingType)sortingType
{
	[SKYConfig setPreferredSortingType:sortingType];
	
	// Refreshes the FRC which will use new sorting.
	if ([self.item hasProperty:SKYPropertyNameEverSynced] == YES) {
		NSFetchedResultsController *frc = [self.persistence fetchedResultsControllerForDirectory:self.item includeDirectories:YES];
		[self.presenter displayDirectoryListingFromFetchedResultsController:frc];
	}
}

@end
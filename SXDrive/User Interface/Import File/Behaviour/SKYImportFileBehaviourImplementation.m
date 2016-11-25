//
//  SKYImportFileBehaviourImplementation.m
//  SXDrive
//
//  Created by Skylable on 5/6/15.
//  Copyright (c) 2015 Skylable. All rights reserved.
//

#import "SKYImportFileBehaviourImplementation.h"

#import "SKYInfoKeys.h"
#import "SKYNotificationNames.h"
#import "SKYPersistence.h"
#import "SKYConfig.h"

@implementation SKYImportFileBehaviourImplementation

@synthesize persistence = _persistence;

- (void)processInfo:(NSDictionary *)info {
    self.presenter.fileSourceURL = info[SKYInfoKeyForURL];
    NSString *fileName = [self.presenter.fileSourceURL lastPathComponent];
    if ([[fileName componentsSeparatedByString:@"."] count] > 1) {
        fileName = [[fileName componentsSeparatedByString:@"."] firstObject];
    }
    self.presenter.fileName = fileName;
    self.presenter.fileExtension = [self.presenter.fileSourceURL pathExtension];
    
    BOOL useDefaultVolume = YES;
    NSArray *itemsURIArray = [SKYConfig importFileItemsURIArray];
    if ([itemsURIArray count] > 0) {
        useDefaultVolume = NO;
        NSMutableArray *tempArray = [NSMutableArray array];
        for (NSURL *uri in itemsURIArray) {
            SKYItem *item = [self.persistence itemForURIRepresentation:uri];
            if (!item) {
                useDefaultVolume = YES;
                break;
            } else if (!item.name) {
                useDefaultVolume = YES;
                break;
            }
            [tempArray addObject:item];
        }
        self.presenter.currentItems = [NSArray arrayWithArray:tempArray];
    }
    
    if (useDefaultVolume) {
        NSFetchedResultsController *frc = [self.persistence fetchedResultsControllerForVolumes];
        [frc performFetch:nil];
        if ([frc.fetchedObjects count] > 0) {
            self.presenter.currentItems = [NSArray arrayWithObject:[frc objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]];
        }
    }
}

- (void)chooseDifferentDirectory {
    [self.viewNavigator navigateFromImportFileController:[self.presenter viewControler] toDirectory:self.presenter.currentItems];
}

- (void)saveFile:(NSDictionary *)file atDirectory:(NSArray *)items {
    if ([self.persistence obtainPermanentIDsForItems:items]) {
        NSMutableArray *tempArray = [NSMutableArray array];
        for (SKYItem *item in items) {
            NSURL *uri = [[item objectID] URIRepresentation];
            [tempArray addObject:uri];
        }
        [SKYConfig setImportFileItemsURIArray:[NSArray arrayWithArray:tempArray]];
    }
    
    [self.viewNavigator navigateToDirectory:items andAddFile:file];
    [self.viewNavigator closeViewController:[self.presenter viewControler]];
}

- (void)cancelImportFile {
    [self.viewNavigator closeViewController:[self.presenter viewControler]];
    [[NSFileManager defaultManager] removeItemAtPath:self.presenter.fileSourceURL error:nil];
}

@end

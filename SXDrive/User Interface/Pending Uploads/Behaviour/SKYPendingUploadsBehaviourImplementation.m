//
//  SKYPendingUploadsBehaviourImplementation.m
//  SXDrive
//
//  Created by Skylable on 16/11/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYPendingUploadsBehaviourImplementation.h"

#import "SKYInfoKeys.h"
#import "SKYNotificationNames.h"

@implementation SKYPendingUploadsBehaviourImplementation

@synthesize persistence = _persistence;
@synthesize item = _item;
@synthesize syncService = _syncService;

- (void)processInfo:(NSDictionary *)info
{
    NSFetchedResultsController *frc;
    if (self.item) {
        frc = [self.persistence fetchedResultsControllerForPendingChangesInDirectory:self.item];
    } else {
        frc = [self.persistence fetchedResultsControllerForCompletedChangesIncludePendingItems:YES];
    }
	[self.presenter displayPendingChangesFromFetchedResultsController:frc];
	
	[[NSNotificationCenter defaultCenter] addObserverForName:SKYUploadProgressDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
		
		[self.presenter displayProgress:[note.userInfo[SKYInfoKeyForUploadProgress] floatValue]
								forItem:note.object];
	}];
}

- (float)uploadProgressForItem:(SKYItem *)item
{
	return [self.persistence uploadProgressForItem:item];
}

- (void)cancelUploadForItem:(SKYItem *)item
{
	[self.syncService cancelUpload:item];
}

- (void)userDidSelectItem:(SKYItem *)item {
    NSDictionary *info = @{
                           SKYInfoKeyForItem: item,
                           SKYInfoKeyShowFavourites: @NO
                           };
    
    [self.viewNavigator navigateFromViewController:[self.presenter viewControler]
                                    toViewWithType:SKYViewTypeFileViewer
                                              info:info
     ];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

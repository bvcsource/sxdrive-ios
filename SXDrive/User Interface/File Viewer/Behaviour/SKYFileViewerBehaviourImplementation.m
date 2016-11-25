//
//  SKYFileViewerBehaviourImplementation.m
//  SXDrive
//
//  Created by Skylable on 19.09.2014.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYFileViewerBehaviourImplementation.h"

#import "SKYInfoKeys.h"
#import "SKYItem+Extras.h"

@interface SKYFileViewerBehaviourImplementation ()

/**
 * YES if used to show for favourites.
 */
@property (nonatomic) BOOL showingFavourites;

@end

@implementation SKYFileViewerBehaviourImplementation

@synthesize persistence = _persistence;

- (void)processInfo:(NSDictionary *)info
{
	SKYItem *selectedItem = info[SKYInfoKeyForItem];
	SKYItem *directoryItem = info[SKYInfoKeyForItemDirectory];
	
	self.showingFavourites = [info[SKYInfoKeyShowFavourites] boolValue];
	
	NSFetchedResultsController *frc = nil;
	if (self.showingFavourites == YES) {
		frc = [self.persistence fetchedResultsControllerForFavourites];
	}
	else if (directoryItem ){
		frc = [self.persistence fetchedResultsControllerForDirectory:directoryItem includeDirectories:NO];
    } else {
        frc = [self.persistence fetchedResultsControllerForCompletedChangesIncludePendingItems:NO];
    }
	
	[self.presenter displayItem:selectedItem andOtherFilesFromFetchedResultsController:frc];
}

- (void)reverseFavouriteStatus:(SKYItem *)item;
{
	if (item.isFavourite.boolValue == YES) {
		[self.persistence removeFavouriteFlagToItem:item];
		if (self.showingFavourites == YES) {
			[self.viewNavigator closeViewController:[self.presenter viewControler]];
		}
	}
	else {
		[self.persistence addFavouriteFlagToItem:item];
	}
}

- (void)performActionForNoMoreItemsToDisplay
{
	[self.viewNavigator closeViewController:[self.presenter viewControler]];
}

- (void)shareItem:(SKYItem *)item
{
	if ([self.persistence isItemDownloaded:item] == YES) {
		[self.presenter displayShareMenuForItem:item];
	}
	else {
		[self.presenter displayShareUnavailableBecauseOfNotDownloadedFile:item];
	}
}

- (void)deleteItem:(SKYItem *)item
{
    if([self.persistence canModifyVolumeWithName:item.volumeName] == YES) {
        [self.persistence removeItem:item];
        [self.viewNavigator closeViewController:[self.presenter viewControler]];
    } else {
        NSString *localizedTitle = NSLocalizedString(@"Delete error", @"Title for alert when a file cannot be deleted.");
        NSString *localizedMessage = NSLocalizedString(@"Cannot delete file from read-only volume", @"Message for alert when a file cannot be deleted from a read-only volume.");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:localizedTitle
                                                        message:localizedMessage
                                                        delegate:self
                                                        cancelButtonTitle:NSLocalizedString(@"OK", @"Generic OK")
                                                        otherButtonTitles:nil];
        [alert show];
    }
}

@end

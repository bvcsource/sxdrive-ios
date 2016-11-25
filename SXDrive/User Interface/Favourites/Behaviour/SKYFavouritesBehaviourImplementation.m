//
//  SKYFavouritesBehaviourImplementation.m
//  SXDrive
//
//  Created by Skylable on 19/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYFavouritesBehaviourImplementation.h"

#import <SSKeychain/SSKeychain.h>

#import "SKYInfoKeys.h"
#import "SKYItem+Extras.h"
#import "SKYPersistenceImplementation.h"
#import "SKYViewType.h"
#import "NSString+Extras.h"
#import "SKYUserImplementation.h"

@interface SKYFavouritesBehaviourImplementation ()

@end

@implementation SKYFavouritesBehaviourImplementation

@synthesize persistence = _persistence;
@synthesize user = _user;

- (void)processInfo:(NSDictionary *)info
{
	NSFetchedResultsController *frc = [self.persistence fetchedResultsControllerForFavourites];
	[self.presenter displayFavouritesFromFetchedResultsController:frc];
}

#pragma mark - SKYFavouritesBehaviour

- (void)userDidSelectItem:(SKYItem *)item
{
	NSDictionary *info = @{
						   SKYInfoKeyForItem: item,
						   SKYInfoKeyShowFavourites: @YES
						   };
	[self.viewNavigator navigateFromViewController:[self.presenter viewControler]
									toViewWithType:SKYViewTypeFileViewer
											  info:info
	 ];
}

// TODO: user wants to remove from favourites method or sth like that below

- (void)showRevisionsForItem:(SKYItem *)item {
#warning Temporary Implementation - support revisions

    NSURL *url;
    NSString *sxWeb = [SSKeychain passwordForService:SKYUserKeychainSXDriveService
                                             account:SKYUserKeychainSXWebAccount];
    if(sxWeb)
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/revs/%@/%@", sxWeb, item.volumeName, [item.name stringByEscapingPath]]];
    else
        url = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.%@/revs/%@/%@", self.user.hostURL, item.volumeName, [item.name stringByEscapingPath]]];
    
    [[UIApplication sharedApplication] openURL:url];
}

@end

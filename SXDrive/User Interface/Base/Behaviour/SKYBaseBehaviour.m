//
//  SKYBaseBehaviour.m
//  SXDrive
//
//  Created by Skylable on 17/09/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYBaseBehaviour.h"
#import "SKYItem.h"
#import "SKYItem+Extras.h"
#import "SKYSyncGeneratePublicLinkAction.h"
#import "SKYInfoKeys.h"

@implementation SKYBaseBehaviourImplementation

@synthesize viewNavigator = _viewNavigator;
@synthesize presenter = _presenter;

#pragma mark - SKYBaseBehaviour

- (void)generatePublicLinkForItem:(SKYItem *)item {
    SKYSyncAction *action = [SKYSyncGeneratePublicLinkAction actionWithItem:item];
    [self.presenter showPublicLinkGeneratingProgressPopup];
    action.completionBlock = ^{
        if(action.cancelled) {
            [self.presenter showPublicLinkGeneratedPopup:false];
        } else {
            NSString *publicLink = [NSString stringWithString:[item propertyValueForName:SKYPropertyNamePublicLink]];
            BOOL success = [publicLink length] > 0;
            if (success) {
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                [pasteboard setString:publicLink];
                [item setPropertyValue:@"" name:SKYPropertyNamePublicLink];
                [self.presenter showPublicLinkGeneratedPopup:success];
            } else
                [self.presenter showPublicLinkGeneratedPopup:false];
        }
    };
    [action syncDirector];
}

@end

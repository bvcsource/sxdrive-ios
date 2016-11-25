//
//  SKYGeneratePublicLinkAction.m
//  SXDrive
//
//  Created by Skylable on 6/12/15.
//  Copyright (c) 2015 Skylable. All rights reserved.
//

#import "SKYSyncGeneratePublicLinkAction.h"
#import "SKYInfoKeys.h"
#import "SKYItem.h"
#import "SKYItem+Extras.h"
#import "SKYPersistence.h"
#import "SKYCloud.h"
#import "NSString+Extras.h"

@interface SKYSyncGeneratePublicLinkAction ()

@property (nonatomic, retain) NSString *publicLink;
@property (assign) NSInteger tries;

/*
 * Generate public link.
 */
- (void)generatePublicLinkAction;

@end

@implementation SKYSyncGeneratePublicLinkAction

+ (instancetype)actionWithItem:(SKYItem *)item
{
    SKYSyncGeneratePublicLinkAction *action = [SKYSyncGeneratePublicLinkAction new];
    action.item = item;
    action.publicLink = nil;
    action.tries = 0;

    return action;
}

- (void)syncDirector {
    if (self.publicLink == nil) {
        if(self.tries++ > 2) {
            [self cancelAction];
            [self failAction];
        } else
            [self generatePublicLinkAction];
    } else {
        [self finishAction];
    }
}

- (void)generatePublicLinkAction {
    NSString *path = [self.item.path stringByAppendingPathComponent:self.item.name];
    [self.cloud publicLinkForFileAtPath:path expireTime:0 password:nil isDirectory:self.item.isDirectory.boolValue completion:^(SKYCloudResponse *response) {
        self.publicLink = response.success ? [response.jsonDictionary valueForKey:@"publink"]:@"";
        [self syncDirector];
    }];
}

- (void)finishAction {
    [self.item setPropertyValue:self.publicLink name:SKYPropertyNamePublicLink];
    [[self.persistence managedObjectContext] save:NULL];
    
    self.completionBlock();
}

- (void)failAction {
    self.completionBlock();
}

@end

//
//  SKYAppDelegate.m
//  SXDrive
//
//  Created by Skylable on 17/09/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYAppDelegate.h"

#import "SKYAppInjector.h"
#import "SKYCloud.h"
#import "SKYErrorManager.h"
#import "SKYInfoKeys.h"
#import "SKYNotificationNames.h"
#import "SKYPersistence.h"
#import "SKYSyncService.h"
#import "SKYUser.h"
#import "SKYVersionPing.h"
#import "SKYViewNavigator.h"
#import "SKYConfig.h"
#import "SKYBackgrounMediaUploadManager.h"

#import <AFNetworking/AFNetworkActivityIndicatorManager.h>

@implementation SKYAppDelegate

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
	NSDictionary *userInfo = @{SKYInfoKeyForURL: url};
    if ([url.absoluteString hasPrefix:@"sx:"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SKYApplicationReceivedActivationURLNotification object:self userInfo:userInfo];
    } else if ([url isFileURL]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SKYApplicationReceivedImportFileNotification object:self userInfo:userInfo];
    }
	
	return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
	});
    
    [SKYAppInjector injectObjectForProtocol:@protocol(SKYErrorManager)];
	[SKYAppInjector injectObjectForProtocol:@protocol(SKYPersistence)];
	[SKYAppInjector injectObjectForProtocol:@protocol(SKYSyncService)];
	[SKYAppInjector injectObjectForProtocol:@protocol(SKYUser)];
	
	id <SKYViewNavigator> viewNavigator = [SKYAppInjector injectObjectForProtocol:@protocol(SKYViewNavigator) info:@{SKYInfoKeyForApplicationMainWindow: self.window}];
	
	[viewNavigator displayApplicationRootController];
	
	[SKYVersionPing ping];
    
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    
    NSDate *currentDate = [NSDate date];
    if (![SKYConfig applicationInstallationDate]) {
        [SKYConfig setApplicationInstallationDate:currentDate];
    }
    [SKYConfig setApplicationLaunchDate:currentDate];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [application registerForRemoteNotifications];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    __block UIBackgroundTaskIdentifier background_task;
    background_task = [application beginBackgroundTaskWithExpirationHandler: ^ {
        [[SKYBackgrounMediaUploadManager manager] cancelUpload];
    }];
    [[SKYBackgrounMediaUploadManager manager] startUploadWithCompletionHandler:^{
        [application endBackgroundTask: background_task];
        background_task = UIBackgroundTaskInvalid;
    }];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[SKYBackgrounMediaUploadManager manager] cancelUpload];
}

@end

//
//  SKYViewNavigatorImplementation.m
//  SXDrive
//
//  Created by Skylable on 18/09/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYViewNavigatorImplementation.h"

#import "SKYAppInjector.h"
#import "SKYConfig.h"
#import "SKYInfoKeys.h"
#import "SKYNavigationController.h"
#import "SKYNotificationNames.h"
#import "SKYUser.h"
#import "SKYItem.h"

@interface SKYViewNavigatorImplementation ()

/**
 * Injected view controller factory.
 */
@property (nonatomic, strong) id <SKYViewControllerFactory> viewControllerFactory;

/**
 * Injected application's main window.
 */
@property (nonatomic, strong) UIWindow *applicationWindow;

/**
 * Contains date when the application was sent to background (for passcode reentry).
 */
@property (nonatomic, strong) NSDate *dateOfApplicationBackground;

/**
 * Checks if user should enter passcode to continue using the app.
 * If it's required the passcode entry screen is displayed.
 */
- (void)displayPasscodeReentryIfNeeded;

/*
 * Presents view controller for file import.
 */
- (void)userWantToImportFile:(NSNotification *)notification;

@end

@implementation SKYViewNavigatorImplementation

- (void)displayApplicationRootController
{
	id <SKYUser> user = [SKYAppInjector injectObjectForProtocol:@protocol(SKYUser)];

	UIViewController *rootVC = nil;
	
	if (user.isUserLoggedIn == NO) {
		id <SKYBaseController> vc = [self.viewControllerFactory createViewControllerForViewType:SKYViewTypeLogin withViewNavigator:self];
		rootVC = [vc viewControler];
	}
	else {
		if ([user isPasscodeProtected] == YES) {
			id <SKYBaseController> vc = [self.viewControllerFactory createViewControllerForViewType:SKYViewTypePasscode withViewNavigator:self];
			SKYNavigationController *nc = [[SKYNavigationController alloc] initWithRootViewController:[vc viewControler]];
			rootVC = nc;
		}
		else {
			id <SKYBaseController> vc = [self.viewControllerFactory createViewControllerForViewType:SKYViewTypeMainTabs withViewNavigator:self];
			rootVC = [vc viewControler];
		}
	}
	
	self.applicationWindow.rootViewController = rootVC;
}

- (instancetype)initWithViewControllerFactory:(id <SKYViewControllerFactory>)viewControllerFactory applicationWindow:(UIWindow *)applicationWindow
{
	self = [super init];
	
	if (self) {
		_viewControllerFactory = viewControllerFactory;
		_applicationWindow = applicationWindow;
		
		[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
			self.dateOfApplicationBackground = [NSDate date];
		}];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayPasscodeReentryIfNeeded) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserverForName:SKYDisplayAlertVCNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
			[self.applicationWindow.rootViewController presentViewController:note.object animated:YES completion:nil];
		}];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userWantToImportFile:) name:SKYApplicationReceivedImportFileNotification object:nil];
	}
	
	return self;
}

- (void)navigateFromViewController:(UIViewController *)fromVC toViewWithType:(SKYViewType)viewType
{
	[self navigateFromViewController:fromVC toViewWithType:viewType info:nil];
}

- (void)navigateFromViewController:(UIViewController *)fromVC toViewWithType:(SKYViewType)viewType info:(NSDictionary *)info
{
    if (viewType == SKYViewTypeSetupWizard) {
        id <SKYBaseController> vc = [self.viewControllerFactory createViewControllerForViewType:SKYViewTypeSetupWizard withViewNavigator:self];
        SKYNavigationController *nc = [[SKYNavigationController alloc] initWithRootViewController:[vc viewControler]];
        nc.modalPresentationStyle = UIModalPresentationFormSheet;
        [fromVC presentViewController:nc animated:YES completion:nil];
    } else if (viewType == SKYViewTypeMainTabs) {
		id <SKYBaseController> vc = [self.viewControllerFactory createViewControllerForViewType:SKYViewTypeMainTabs withViewNavigator:self];
		vc.info = info;
		
		// this assignment has to be outside of the animation block
		self.applicationWindow.rootViewController = [vc viewControler];
		[UIView transitionWithView:self.applicationWindow
						  duration:0.4
						   options:UIViewAnimationOptionTransitionCrossDissolve
						animations:nil
						completion:nil];
	}
	else if (viewType == SKYViewTypeLogin) {
		id <SKYBaseController> vc = [self.viewControllerFactory createViewControllerForViewType:SKYViewTypeLogin withViewNavigator:self];
		vc.info = info;
		
		// this assignment has to be outside of the animation block
		self.applicationWindow.rootViewController = [vc viewControler];
		[UIView transitionWithView:self.applicationWindow
						  duration:0.4
						   options:UIViewAnimationOptionTransitionCrossDissolve
						animations:nil
						completion:nil];

	}
	else {
		id <SKYBaseController> vc = [self.viewControllerFactory createViewControllerForViewType:viewType withViewNavigator:self];
		vc.info = info;
		
        BOOL animated = YES;
        if (info[SKYInfoKeyForAnimation]) {
            animated = [info[SKYInfoKeyForAnimation] boolValue];
        }
        
		[fromVC.navigationController pushViewController:[vc viewControler] animated:animated];
	}
}

- (void)closeViewController:(UIViewController *)vcToClose
{
    SKYViewType viewType = [vcToClose respondsToSelector:@selector(viewType)] ? (SKYViewType)[vcToClose performSelector:@selector(viewType)]:SKYViewTypeNone;
	if (vcToClose.navigationController != nil) {
		if (vcToClose.navigationController.viewControllers.count > 1) {
			[vcToClose.navigationController popViewControllerAnimated:YES];
		}
		else {
			if (vcToClose.navigationController == self.applicationWindow.rootViewController) {
				[self navigateFromViewController:vcToClose toViewWithType:SKYViewTypeMainTabs];
			}
			else {
                [vcToClose.navigationController dismissViewControllerAnimated:YES completion:^{
                    if (viewType == SKYViewTypePasscode && [SKYConfig importFileURL]) {
                        [self displayImportFileInterfaceAnimated:YES];
                    }
                }];
			}
		}
	}
}

- (void)displayPasscodeReentryIfNeeded
{
	id <SKYUser> user = [SKYAppInjector injectObjectForProtocol:@protocol(SKYUser)];

	if ([user isPasscodeProtected] == YES) {
		NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.dateOfApplicationBackground];
		
		if (timeInterval > SKYConfigTimeIntervalForPasscodeReentry) {
			id <SKYBaseController> vc = [self.viewControllerFactory createViewControllerForViewType:SKYViewTypePasscode withViewNavigator:self];
			SKYNavigationController *nc = [[SKYNavigationController alloc] initWithRootViewController:[vc viewControler]];
			
			[self.applicationWindow.rootViewController presentViewController:nc animated:YES completion:nil];
		}
	}
}

- (void)userWantToImportFile:(NSNotification *)notification {
    [SKYConfig setImportFileURL:notification.userInfo[SKYInfoKeyForURL]];
    
    id <SKYUser> user = [SKYAppInjector injectObjectForProtocol:@protocol(SKYUser)];
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.dateOfApplicationBackground];
    if ([user isUserLoggedIn] && ([user isPasscodeProtected] == NO || ([user isPasscodeProtected] == YES && timeInterval < SKYConfigTimeIntervalForPasscodeReentry))) {
        [self displayImportFileInterfaceAnimated:NO];
    }
}

- (void)returnFromViewController:(UIViewController *)fromVC toViewWithType:(SKYViewType)viewType
{
	NSArray *controllers = fromVC.navigationController.viewControllers;
	
	for (int i = (int)controllers.count - 1; i >= 0; i--) {
		id <SKYBaseController> controller = controllers[i];
		if ([controller viewType] == viewType) {
			[fromVC.navigationController popToViewController:[controller viewControler] animated:YES];
			break;
		}
	}
}

- (void)navigateToDirectory:(NSArray *)items andAddFile:(NSDictionary *)file {
    if ([self.applicationWindow.rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)self.applicationWindow.rootViewController;
        tabBarController.selectedIndex = 0;
        SKYNavigationController *volumesNC = (SKYNavigationController *)[tabBarController.viewControllers firstObject];
        [volumesNC popToRootViewControllerAnimated:NO];
        UIViewController *vc = [volumesNC.viewControllers firstObject];
        for (SKYItem *item in items) {
            NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:item, SKYInfoKeyForItem, [NSNumber numberWithBool:NO], SKYInfoKeyForAnimation, nil];
            if (item == [items lastObject]) {
                [dictionary setObject:file forKey:SKYInfoKeyForImportFile];
            }
            [self navigateFromViewController:vc toViewWithType:SKYViewTypeBrowseDirectory info:[NSDictionary dictionaryWithDictionary:dictionary]];
        }
    }
}

- (void)displayImportFileInterfaceAnimated:(BOOL)animated {
    id <SKYBaseController> vc = [self.viewControllerFactory createViewControllerForViewType:SKYViewTypeImportFile withViewNavigator:self];
    vc.info = @{SKYInfoKeyForURL: [SKYConfig importFileURL]};
    [SKYConfig removeImportFileURL];
    SKYNavigationController *nc = [[SKYNavigationController alloc] initWithRootViewController:[vc viewControler]];
    nc.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.applicationWindow.rootViewController presentViewController:nc animated:animated completion:nil];
}

- (void)navigateFromImportFileController:(UIViewController *)fromVC toDirectory:(NSArray *)items {
    NSDictionary *coreInfo = [NSDictionary dictionaryWithObjectsAndKeys:SKYBrowserModeChooseDirectory, SKYInfoKeyForBrowserMode, fromVC, SKYInfoKeyForImpoerFileControllerReference, nil];
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:fromVC.navigationController.viewControllers];
    id <SKYBaseController> vc = [self.viewControllerFactory createViewControllerForViewType:SKYViewTypeVolumes withViewNavigator:self];
    vc.info = coreInfo;
    [viewControllers addObject:vc];
    for (SKYItem *item in items) {
        vc = [self.viewControllerFactory createViewControllerForViewType:SKYViewTypeBrowseDirectory withViewNavigator:self];
        NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:coreInfo];
        [info setObject:item forKey:SKYInfoKeyForItem];
        vc.info = info;
        [viewControllers addObject:vc];
    }
    [fromVC.navigationController setViewControllers:viewControllers animated:YES];
}

- (void)navigateFromBackgroundUploadSettingsControllerToVolumesController:(UIViewController *)fromVC {
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:SKYBrowserModeChooseDirectory, SKYInfoKeyForBrowserMode, fromVC, SKYInfoKeyForBackgroundUploadSettingsControllerReference, nil];
    id <SKYBaseController> vc = [self.viewControllerFactory createViewControllerForViewType:SKYViewTypeVolumes withViewNavigator:self];
    vc.info = info;
    SKYNavigationController *nc = [[SKYNavigationController alloc] initWithRootViewController:[vc viewControler]];
    nc.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.applicationWindow.rootViewController presentViewController:nc animated:YES completion:nil];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

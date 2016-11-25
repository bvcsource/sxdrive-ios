//
//  SKYViewControllerFactoryImplementation.m
//  SXDrive
//
//  Created by Skylable on 18/09/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYViewControllerFactoryImplementation.h"

#import "SKYBrowseDirectoryInjector.h"
#import "SKYFavouritesInjector.h"
#import "SKYFileViewerInjector.h"
#import "SKYLoginInjector.h"
#import "SKYMainTabsInjector.h"
#import "SKYNavigationController.h"
#import "SKYPasscodeInjector.h"
#import "SKYPendingUploadsInjector.h"
#import "SKYSettingsInjector.h"
#import "SKYSingleFileInjector.h"
#import "SKYVolumesInjector.h"
#import "SKYSetupWizardInjector.h"
#import "SKYImportFileInjector.h"
#import "SKYBackgroundUploadSettingsInjector.h"
#import "SKYAdvancedSettingsInjector.h"
#import "SKYPendingUploadsInjector.h"

@implementation SKYViewControllerFactoryImplementation

- (id <SKYBaseController>)createViewControllerForViewType:(SKYViewType)viewType withViewNavigator:(id <SKYViewNavigator>)viewNavigator
{
	id <SKYBaseController> vc = nil;
	
	switch (viewType) {
		case SKYViewTypeNone: {
			NSAssert(NO, @"SKYViewTypeNone should never be used.");
		}
		case SKYViewTypeBrowseDirectory: {
			vc = [SKYBrowseDirectoryInjector injectViewControllerWithViewNavigator:viewNavigator];
			break;
		}
		case SKYViewTypeFileViewer: {
			vc = [SKYFileViewerInjector injectViewControllerWithViewNavigator:viewNavigator];
			break;
		}
		case SKYViewTypeLogin: {
			vc = [SKYLoginInjector injectViewControllerWithViewNavigator:viewNavigator];
			break;
		}
		case SKYViewTypeSettings: {
			vc = [SKYSettingsInjector injectViewControllerWithViewNavigator:viewNavigator];
			break;
		}
		case SKYViewTypeVolumes: {
			vc = [SKYVolumesInjector injectViewControllerWithViewNavigator:viewNavigator];
			break;
		}
		case SKYViewTypeFavourites: {
			vc = [SKYFavouritesInjector injectViewControllerWithViewNavigator:viewNavigator];
			break;
		}
		case SKYViewTypeMainTabs: {
			vc = [SKYMainTabsInjector injectViewControllerWithViewNavigator:viewNavigator];
			break;
		}
		case SKYViewTypePasscode: {
			vc = [SKYPasscodeInjector injectViewControllerWithViewNavigator:viewNavigator];
			[vc setInfo:@{}];
			break;
		}
        case SKYViewTypeSetupWizard: {
            vc = [SKYSetupWizardInjector injectViewControllerWithViewNavigator:viewNavigator];
            break;
        }
        case SKYViewTypeImportFile: {
            vc = [SKYImportFileInjector injectViewControllerWithViewNavigator:viewNavigator];
            break;
        }
        case SKYViewTypeBackgroundUploadSettings: {
            vc = [SKYBackgroundUploadSettingsInjector injectViewControllerWithViewNavigator:viewNavigator];
            break;
        }
        case SKYViewTypeAdvancedSettings: {
            vc = [SKYAdvancedSettingsInjector injectViewControllerWithViewNavigator:viewNavigator];
            break;
        }
        case SKYViewTypePendingUploads: {
            vc = [SKYPendingUploadsInjector injectViewControllerWithViewNavigator:viewNavigator];
            break;
        }
		case SKYViewTypeSingleFile:
		{
			NSAssert(NO, @"This controller cannot be created with this factory.");
		}
	}
	
	return vc;
}

@end

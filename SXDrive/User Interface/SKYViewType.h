//
//  SKYViewType.h
//  SXDrive
//
//  Created by Skylable on 18/09/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

@import Foundation;

/**
 * Enumeration of view types.
 */
typedef NS_ENUM(NSUInteger, SKYViewType) {
	/**
	 * Abstract type for abstract classes.
	 */
	SKYViewTypeNone,
	
	/**
	 * Type for browse directory view.
	 */
	SKYViewTypeBrowseDirectory,
	
	/**
	 * Type for file viewer view.
	 */
	SKYViewTypeFileViewer,
	
	/**
	 * Type for login view.
	 */
	SKYViewTypeLogin,
	
	/**
	 * Type for settings view.
	 */
	SKYViewTypeSettings,
	
	/**
	 * Type for single file view.
	 */
	SKYViewTypeSingleFile,
	
	/**
	 * Type for volumes view.
	 */
	SKYViewTypeVolumes,
	
	/**
	 * Type for favourites view.
	 */
	SKYViewTypeFavourites,
	
	/**
	 * Type for view which shows 3 tabs - Volumes, Favourites, Settings.
	 */
	SKYViewTypeMainTabs,
	
	/**
	 * Type for passcode view.
	 */
	SKYViewTypePasscode,
	
	/**
	 * Type for pending uploads.
	 */
	SKYViewTypePendingUploads,
    
    /**
     * Type for setup wizard.
     */
    SKYViewTypeSetupWizard,
    /**
     * Type for import file.
     */
    SKYViewTypeImportFile,
    
    /**
     * Type for auto sync camera roll settings view.
     */
    SKYViewTypeBackgroundUploadSettings,
    
    /**
     * Type for advanced settings view.
     */
    SKYViewTypeAdvancedSettings
};

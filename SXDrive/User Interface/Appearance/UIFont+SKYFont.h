//
//  UIFont+SKYFont.h
//  SXDrive
//
//  Created by Skylable on 21/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import <UIKit/UIKit.h>

/**
 * Category containing fonts used by this application.
 */
@interface UIFont (SKYFont)

/**
 * @return Font used for no files label.
 */
+ (UIFont *)fontForNoFilesLabel;

/**
 * @return Font used for volume size labels.
 */
+ (UIFont *)fontForVolumeSize;

/**
 * @return Font used for volume name labels.
 */
+ (UIFont *)fontForVolumeName;

/**
 * @return Font used to render filenames on lists.
 */
+ (UIFont *)fontForFilenameOnLists;

/**
 * @return Font used to render file sizes and dates on lists.
 */
+ (UIFont *)fontForFileInfoTextsOnLists;

/**
 * @return Font used to render directory names on lists.
 */
+ (UIFont *)fontForDirectoryNamesOnLists;

/**
 * @return Font used to render placeholders and user input on lists.
 */
+ (UIFont *)fontForTextCells;

/**
 * @return Font used to render bar texts (navigation bar titles, buttons, toolbar buttons).
 */
+ (UIFont *)fontForBarTexts;

/**
 * @return Font used to render no favourites title.
 */
+ (UIFont *)fontForNoFavouritesTitle;

/**
 * @return Font used to render no favourites subtitle.
 */
+ (UIFont *)fontForNoFavouritesSubtitle;

/**
 * @return Font used to render overlay cell labels.
 */
+ (UIFont *)fontForOverlayCellLabels;

/**
 * @return Font used to render login screen title.
 */
+ (UIFont *)fontForLoginScreenTitle;

/**
 * @return Font used to render login screen 'Login' button title.
 */
+ (UIFont *)fontForLoginScreenButton;

/**
 * @return Font used to render app's name on login screen.
 */
+ (UIFont *)fontForLoginScreenTitleAppName;

/**
 * @return Font used to render login screen subtitle.
 */
+ (UIFont *)fontForLoginScreenSubtitle;

/**
 * @return Font used on passcode screen.
 */
+ (UIFont *)fontForPasscodeScreen;

/**
 * @return Font used on standard cell labels.
 */
+ (UIFont *)fontForStandardCellLabels;

/**
 * @return Font used on detail cell labels.
 */
+ (UIFont *)fontForDetailCellLabels;

/**
 * @return Font used on file viewer to render filename.
 */
+ (UIFont *)fontForFilenameLabelOnFileViewer;

/**
 * @return Font used on file viewer to render file details.
 */
+ (UIFont *)fontForFileDetailsLabelOnFileViewer;

/**
 * @return Font used on file viewer to render play media button.
 */
+ (UIFont *)fontForPlayMediaButtonOnFileViewer;

@end

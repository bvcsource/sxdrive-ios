//
//  UIColor+SKYColor.h
//  SXDrive
//
//  Created by Skylable on 13/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

@import UIKit;

/**
 * Category containing colors used by this application.
 */
@interface UIColor (SKYColor)

/**
 * @return Main color used in application.
 */
+ (UIColor *)skyMainColor;

/**
 * @return Color used for grid lines.
 */
+ (UIColor *)skyGridLinesColor;

/**
 * @return Color used for selection checkmark.
 */
+ (UIColor *)skyColorForSelectionCheckmark;

/**
 * @return Color used for volume size labels.
 */
+ (UIColor *)skyColorForVolumeSizeText;

/**
 * @return Color used for selected state.
 */
+ (UIColor *)skySelectionBackgroundColor;

/**
 * @return Color used on lists to present file sizes and dates.
 */
+ (UIColor *)skyColorForFileInfo;

/**
 * @return Color used for no favourites subtitle.
 */
+ (UIColor *)skyColorForNoFavouritesSubtitle;

/**
 * @return Color used for cell labels on overlays.
 */
+ (UIColor *)skyColorForOverlayCellLabels;

/**
 * @return Color used in footer on login screen.
 */
+ (UIColor *)skyColorForLoginFooter;

/**
 * @return Color used for delete (like trash icon, delete text).
 */
+ (UIColor *)skyColorForDelete;

/**
 * @return Color for logout text.
 */
+ (UIColor *)skyColorForLogoutText;

/**
 * @return Color for tab bar.
 */
+ (UIColor *)skyColorForTabBar;

/**
 * @return Color for tab bar separator.
 */
+ (UIColor *)skyColorForTabBarSeparator;

/**
 * @return Color for pending upload cell background.
 */
+ (UIColor *)skyColorForPendingUploadCellBackground;

@end

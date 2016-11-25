//
//  UIColor+SKYColor.m
//  SXDrive
//
//  Created by Skylable on 13/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "UIColor+SKYColor.h"

@implementation UIColor (SKYColor)

+ (UIColor *)skyMainColor
{
	return [UIColor colorWithRed:030.f / 255.f
						   green:119.f / 255.f
							blue:194.f / 255.f
						   alpha:1.f];
}

+ (UIColor *)skyGridLinesColor
{
	return [UIColor colorWithRed:200.f / 255.f
						   green:199.f / 255.f
							blue:204.f / 255.f
						   alpha:1.f];
}

+ (UIColor *)skyColorForSelectionCheckmark
{
	return [UIColor colorWithRed:090.f / 255.f
						   green:098.f / 255.f
							blue:118.f / 255.f
						   alpha:1.f];
}

+ (UIColor *)skyColorForVolumeSizeText
{
	return [UIColor colorWithRed:205.f / 255.f
						   green:205.f / 255.f
							blue:205.f / 255.f
						   alpha:1.f];
}

+ (UIColor *)skySelectionBackgroundColor
{
	return [UIColor colorWithWhite:217.f / 255.f
							 alpha:1.f];
}

+ (UIColor *)skyColorForFileInfo
{
	return [UIColor colorWithWhite:166.f / 255.f
							 alpha:1.f];
}

+ (UIColor *)skyColorForNoFavouritesSubtitle
{
	return [UIColor colorWithWhite:166.f / 255.f
							 alpha:1.f];
}

+ (UIColor *)skyColorForOverlayCellLabels
{
	return [UIColor colorWithRed:18.f / 255.f
						   green:120.f / 255.f
							blue:189.f / 255.f
						   alpha:1.f];
}

+ (UIColor *)skyColorForLoginFooter
{
	return [UIColor colorWithWhite:253.f / 255.f
							 alpha:1.f];
}

+ (UIColor *)skyColorForDelete
{
	return [UIColor colorWithRed:252.f / 255.f
						   green:61.f / 255.f
							blue:57.f / 255.f
						   alpha:1.f];
}

+ (UIColor *)skyColorForLogoutText
{
	return [UIColor colorWithRed:252.f / 255.f
						   green:61.f / 255.f
							blue:57.f / 255.f
						   alpha:1.f];
}

+ (UIColor *)skyColorForTabBar
{
	return [UIColor colorWithWhite:246.f / 255.f
							 alpha:1.f];
}

+ (UIColor *)skyColorForTabBarSeparator
{
	return [UIColor colorWithRed:211.f / 255.f
						   green:210.f / 255.f
							blue:213.f / 255.f
						   alpha:1.f];
}

+ (UIColor *)skyColorForPendingUploadCellBackground
{
	return [UIColor colorWithWhite:246.f / 255.f
							 alpha:1.f];
}

@end

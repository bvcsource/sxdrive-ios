//
//  UIFont+SKYFont.m
//  SXDrive
//
//  Created by Skylable on 21/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "UIFont+SKYFont.h"

@implementation UIFont (SKYFont)

+ (UIFont *)fontForNoFilesLabel
{
	return [UIFont fontWithName:@"OpenSans" size:13.f];
}

+ (UIFont *)fontForVolumeSize
{
	return [UIFont fontWithName:@"OpenSans" size:10.f];
}

+ (UIFont *)fontForVolumeName
{
	return [UIFont fontWithName:@"OpenSans" size:13.f];
}

+ (UIFont *)fontForFilenameOnLists
{
	return [UIFont fontWithName:@"OpenSans" size:13.f];
}

+ (UIFont *)fontForFileInfoTextsOnLists
{
	return [UIFont fontWithName:@"OpenSans" size:11.f];
}

+ (UIFont *)fontForDirectoryNamesOnLists
{
	return [UIFont fontWithName:@"OpenSans" size:16.f];
}

+ (UIFont *)fontForTextCells
{
	return [UIFont fontWithName:@"OpenSans" size:15.f];
}

+ (UIFont *)fontForBarTexts
{
	return [UIFont fontWithName:@"OpenSans" size:17.f];
}

+ (UIFont *)fontForNoFavouritesTitle
{
	return [UIFont fontWithName:@"OpenSans" size:13.f];
}

+ (UIFont *)fontForNoFavouritesSubtitle
{
	return [UIFont fontWithName:@"OpenSans" size:11.f];
}

+ (UIFont *)fontForOverlayCellLabels
{
	return [UIFont fontWithName:@"OpenSans" size:16.f];
}

+ (UIFont *)fontForLoginScreenTitle
{
	return [UIFont fontWithName:@"OpenSans" size:15.f];
}

+ (UIFont *)fontForLoginScreenButton
{
    return [UIFont fontWithName:@"OpenSans" size:18.f];
}

+ (UIFont *)fontForLoginScreenTitleAppName
{
	return [UIFont fontWithName:@"OpenSans-Bold" size:15.f];
}

+ (UIFont *)fontForLoginScreenSubtitle
{
	return [UIFont fontWithName:@"OpenSans" size:12.f];
}

+ (UIFont *)fontForPasscodeScreen
{
	return [UIFont fontWithName:@"OpenSans" size:13.f];
}

+ (UIFont *)fontForStandardCellLabels
{
	return [UIFont fontWithName:@"OpenSans" size:17.f];
}

+ (UIFont *)fontForDetailCellLabels
{
	return [UIFont fontWithName:@"OpenSans" size:14.f];
}

+ (UIFont *)fontForFilenameLabelOnFileViewer
{
	return [UIFont fontWithName:@"OpenSans" size:14.f];
}

+ (UIFont *)fontForFileDetailsLabelOnFileViewer
{
	return [UIFont fontWithName:@"OpenSans" size:12.f];
}

+ (UIFont *)fontForPlayMediaButtonOnFileViewer
{
	return [UIFont fontWithName:@"OpenSans" size:15.f];
}

@end

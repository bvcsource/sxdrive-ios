//
//  UIImage+SKYImage.m
//  SXDrive
//
//  Created by Skylable on 13/11/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "UIImage+SKYImage.h"
#import "NSFileManager+Extras.h"

@implementation UIImage (SKYImage)

+ (UIImage *)iconImageForFileWithName:(NSString *)filename
{
	return [self iconImageForFileWithName:filename largeIcon:NO];
}

+ (UIImage *)iconImageForFileWithName:(NSString *)filename largeIcon:(BOOL)largeIcon
{
	// TODO largeIcon
	
	NSString *extension = [filename pathExtension].lowercaseString;
	
	NSString *imageName = @"blank-icon";
	
	if ([extension isEqualToString:@"ai"] == YES) {
		imageName = @"ai-icon";
	}
	else if ([@[@"htm", @"html"] containsObject:extension] == YES) {
		imageName = @"html-icon";
	}
	else if ([@[@"doc", @"docx", @"pages", @"rtf", @"txt"] containsObject:extension] == YES) {
		imageName = @"icon-doc";
	}
	else if ([extension isEqualToString:@"xml"] == YES) {
		imageName = @"icon-xml";
	}
	else if ([NSFileManager isFileOfImageType:filename] == YES) {
		imageName = @"image-icon";
	}
	else if ([NSFileManager isFileOfMovieType:filename] == YES) {
		imageName = @"movie-icon";
	}
	else if ([NSFileManager isFileOfMusicType:filename] == YES) {
		imageName = @"music-icon";
	}
	else if ([extension isEqualToString:@"pdf"] == YES) {
		imageName = @"pdf-icon";
	}
	else if ([@[@"ppt", @"keynote", @"xls", @"numbers"] containsObject:extension] == YES) {
		imageName = @"ppt-icon";
	}
	else if ([@[@"zip", @"rar", @"tar", @"gz", @"7z", @"jar"] containsObject:extension] == YES == YES) {
		imageName = @"zip-icon";
	}
	
	return [UIImage imageNamed:imageName];
}

+ (UIImage *)iconImageForFileWithName:(NSString *)filename isDirectory:(BOOL)isDirectory
{
	if (isDirectory == YES) {
		return [UIImage imageNamed:@"folder"];
	}
	else {
		return [self iconImageForFileWithName:filename];
	}
}

+ (UIImage *)iconImageForVolumeLocked:(BOOL)locked encrypted:(BOOL)encrypted {
    NSString *imageName =[NSString stringWithFormat:@"%@%@volume", encrypted ? @"encrypted-":@"", locked ? @"locked":@"unlocked"];
	return [UIImage imageNamed:imageName];
}

@end

//
//  UIImage+SKYImage.h
//  SXDrive
//
//  Created by Skylable on 13/11/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

@import UIKit;

/**
 * Dynamic images category.
 */
@interface UIImage (SKYImage)

/**
 * Returns the most appropriate icon for given filename.
 * @param filename Filename.
 * @return Icon.
 */
+ (UIImage *)iconImageForFileWithName:(NSString *)filename;

/**
 * Returns the most appropriate icon for given filename.
 * @param filename  Filename.
 * @param largeIcon YES if large icon should be provided, NO otherwise.
 * @return Icon.
 */
+ (UIImage *)iconImageForFileWithName:(NSString *)filename largeIcon:(BOOL)largeIcon;

/**
 * Returns the most appropriate icon for given filename.
 * @param filename Filename (or directory name).
 * @param isDirectory YES if directory, no otherwise.
 * @return Icon.
 */
+ (UIImage *)iconImageForFileWithName:(NSString *)filename isDirectory:(BOOL)isDirectory;

/**
 * Returns the most appropriate icon for volume.
 * @param locked    YES if volume is locked, NO otherwise.
 * @param encrypted YES if volume is encrypted, NO otherwise.
 * @return Icon.
 */
+ (UIImage *)iconImageForVolumeLocked:(BOOL)locked encrypted:(BOOL)encrypted;

@end

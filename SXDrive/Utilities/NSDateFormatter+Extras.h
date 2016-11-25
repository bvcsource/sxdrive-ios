//
//  NSDateFormatter+Extras.h
//  SXDrive
//
//  Created by Skylable on 22/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import <Foundation/Foundation.h>

/**
 * Extra extensions to NSDateFormatter class.
 */
@interface NSDateFormatter (Extras)

/**
 * Returns date formatter for presenting modification (or creation) dates.
 * This object creates only one instance of date formatter.
 * @return Date formatter.
 */
+ (NSDateFormatter *)dateFormatterForLastModificationDate;

/**
 * Returns date formatter for media names.
 * This object creates only one instance of date formatter.
 * @return Date formatter.
 */
+ (NSDateFormatter *)dateFormatterForMediaNames;

@end

//
//  NSDateFormatter+Extras.m
//  SXDrive
//
//  Created by Skylable on 22/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "NSDateFormatter+Extras.h"

@implementation NSDateFormatter (Extras)

+ (NSDateFormatter *)dateFormatterForLastModificationDate
{
	static dispatch_once_t onceToken;
	static NSDateFormatter * dateFormatter;
	dispatch_once(&onceToken, ^{
		dateFormatter = [[NSDateFormatter alloc] init];
		dateFormatter.dateStyle = NSDateFormatterMediumStyle;
		dateFormatter.timeStyle = NSDateFormatterShortStyle;
	});
	
	return dateFormatter;
}

+ (NSDateFormatter *)dateFormatterForMediaNames
{
	static dispatch_once_t onceToken;
	static NSDateFormatter * dateFormatter;
	dispatch_once(&onceToken, ^{
		dateFormatter = [[NSDateFormatter alloc] init];
		dateFormatter.dateFormat = @"yyyy-MM-dd_HH-mm-ss-SSS";
	});
	
	return dateFormatter;
}

@end

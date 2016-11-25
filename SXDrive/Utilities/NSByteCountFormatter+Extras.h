//
//  NSByteCountFormatter+Extras.h
//  SXDrive
//
//  Created by Skylable on 19/11/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

@import Foundation;

/**
 * Extra extensions to NSByteCountFormatter class.
 */
@interface NSByteCountFormatter (Extras)

/**
 * Returns size string (5 MB, 1 KB, 0 B) from given byte count.
 * @param byteCount Byte count.
 * @return Formatted size string.
 */
+ (NSString *)skyStringWithByteCount:(long long)byteCount;

@end

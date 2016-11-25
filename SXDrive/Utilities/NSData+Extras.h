//
//  NSData+Extras.h
//  SXDrive
//
//  Created by Skylable on 06.10.2014.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

@import Foundation;

/**
 * Extra extensions to NSData class.
 */
@interface NSData (Extras)

/**
 * Creates hex string from receiver.
 * @return Hex string.
 */
- (NSString *)skyHexString;

/**
 * Returns SHA1 hash of the receiver.
 * @return SHA1 hash of the receiver.
 */
- (NSString *)SHA1;

/**
 * Creates data based on the given hex string.
 * @param hexString Hex string.
 * @return Data.
 */
+ (NSData *)dataWithHextString:(NSString *)hexString;

@end

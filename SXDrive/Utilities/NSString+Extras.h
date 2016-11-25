//
//  NSString+Extras.h
//  SXDrive
//
//  Created by Skylable on 18.09.2014.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

@import Foundation;

/**
 * Extra extensions to NSString class.
 */
@interface NSString (Extras)

/**
 * Returns SHA1 hash of the receiver.
 * @return SHA1 hash of the receiver.
 */
- (NSString *)SHA1;

/**
 * Returns HMAC-SHA1 of the receiver with a given key.
 * @param key Key as string.
 * @return HMAC-SHA1 of the receiver.
 */
- (NSString *)HMAC_SHA1WithKey:(NSString *)key;

/**
 * Returns HMAC-SHA1 of the receiver with a given data as a key.
 * @param key Key as data.
 * @return HMAC-SHA1 of the receiver.
 */
- (NSString *)HMAC_SHA1WithKeyData:(NSData *)key;

/**
 * Returns random string containing 32 hex characters.
 * @return Random string containing 32 hex characters.
 */
+ (NSString *)randomString;

/**
 * Returns random string containing given amount of hex characters.
 * @param length Length of random string.
 * @return Random string of given length.
 */
+ (NSString *)randomStringOfLength:(NSUInteger)length;

/**
 * Returns name that is unique compared to other names, by adding extra suffix (_1, _2...) if needed.
 * @param name  Planned name.
 * @param names Used names.
 * @return Unique name.
 */
+ (NSString *)stringWithName:(NSString *)name withAvoidingNameClashWithExistingNames:(NSArray *)names;

/**
 * Adds escape characters to given path.
 * @return Escaped path.
 */
- (NSString *)stringByEscapingPath;

@end

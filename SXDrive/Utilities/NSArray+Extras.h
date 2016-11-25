//
//  NSArray+Extras.h
//  SXDrive
//
//  Created by Skylable on 11/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import <Foundation/Foundation.h>

/**
 * Extra extensions to NSArray class.
 */
@interface NSArray (Extras)

/**
 * Returns random object from array.
 * @return Random object or nil for empty array.
 */
- (id)randomObject;

/**
 * Returns middle object in the array.
 * @return Array with single object that is in the middle of the receiver if the receiver's count is odd.
 * @return Array with two object that are in the middle of the receiver if the receiver's count is even.
 * @return Copy of receiver if receiver's count is one or two.
 * @return Nil for empty array.
 
 */
- (NSArray *)middleObjects;

@end

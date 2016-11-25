//
//  SKYOverlay.h
//  SXDrive
//
//  Created by Skylable on 11/11/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

@import UIKit;

/**
 * Base class for overlay.
 */
@interface SKYOverlay : UIView <UITableViewDelegate, UITableViewDataSource>

/**
 * Navigation bar for proper top spacing.
 */
@property (nonatomic, strong) UINavigationBar *navigationBar;

/**
 * Helper method to create subviews, called during initialization.
 */
- (void)createSubviews;

/**
 * Removes overlay with animation.
 */
- (void)dismissOverlay;

/**
 * Runs the presentation animation.
 */
- (void)animateEntry;

/**
 * Displays arrow with given position.
 *
 * @param rightCenterDistance Arrow center from right edge of the screen.
 */
- (void)displayArrowWithCenterAtDistanceFromRightEdge:(CGFloat)rightCenterDistance;

@end

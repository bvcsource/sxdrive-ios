//
//  SKYAddContentOverlay.h
//  SXDrive
//
//  Created by Skylable on 11/11/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYOverlay.h"

@protocol SKYAddContentOverlayDelegate;

/**
 * Overlay for adding directories and files.
 */
@interface SKYAddContentOverlay : SKYOverlay

/**
 * Overlay's delegate.
 */
@property (nonatomic, weak) id <SKYAddContentOverlayDelegate> delegate;

@end

/**
 * Delegate for action caused on add content overlay.
 */
@protocol SKYAddContentOverlayDelegate <NSObject>

/**
 * Called when user presses the add new directory cell.
 *
 * @param overlay Overlay which send this action.
 */
- (void)addContentOverlayDidChooseAddNewDirectory:(SKYAddContentOverlay *)overlay;

/**
 * Called when user presses the add new file cell.
 *
 * @param overlay Overlay which send this action.
 */
- (void)addContentOverlayDidChooseAddNewFile:(SKYAddContentOverlay *)overlay;

@end

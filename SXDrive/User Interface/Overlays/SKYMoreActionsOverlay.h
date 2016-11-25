//
//  SKYMoreActionsOverlay.h
//  SXDrive
//
//  Created by Skylable on 12/11/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYOverlay.h"

#import "SKYConfig.h"

@protocol SKYMoreActionsOverlayDelegate;

/**
 * Overlay for more actions.
 */
@interface SKYMoreActionsOverlay : SKYOverlay

/**
 * Presenting view controller.
 */
@property (nonatomic, weak) UIViewController *presentingViewController;

/**
 * Overlay's delegate.
 */
@property (nonatomic, weak) id <SKYMoreActionsOverlayDelegate> delegate;

@end

/**
 * Delegate for action caused on add content overlay.
 */
@protocol SKYMoreActionsOverlayDelegate <NSObject>

/**
 * Called when user wants to change sorting type.
 * @param overlay     Overlay which send this action.
 * @param sortingType Chosen sorting type.
 */
- (void)moreActionsOverlay:(SKYMoreActionsOverlay *)overlay didChangeSortingType:(SKYConfigSortingType)sortingType;

/**
 * Called when user wants to reverse the selecting state.
 * @param overlay Overlay which send this action.
 */
- (void)moreActionsOverlayDidChangeSelectingState:(SKYMoreActionsOverlay *)overlay;

@end

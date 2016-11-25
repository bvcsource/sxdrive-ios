//
//  SKYBrowseDirectoryMultipleSelectionBottomBar.h
//  SXDrive
//
//  Created by Skylable on 20/11/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

@import UIKit;

@protocol SKYBrowseDirectoryMultipleSelectionBottomBarDelegate;

/**
 * Bottom bar replacing tabbar displayed when user is in selection mode.
 */
@interface SKYBrowseDirectoryMultipleSelectionBottomBar : UIView

@property (nonatomic, weak) id <SKYBrowseDirectoryMultipleSelectionBottomBarDelegate> delegate;

/**
 * Sets control enabled/disabled.
 * @param enabled YES if controls should be enabled, NO otherwise.
 */
- (void)setControlsEnabled:(BOOL)enabled;

@end

@protocol SKYBrowseDirectoryMultipleSelectionBottomBarDelegate <NSObject>

/**
 * Called when user presses delete button.
 *
 * @param multipleSelectionBottomBar Multiple selection bottom bar.
 */
- (void)multipleSelectionBottomBarDidPressDelete:(SKYBrowseDirectoryMultipleSelectionBottomBar *)multipleSelectionBottomBar;

@end

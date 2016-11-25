//
//  SKYLoginView.h
//  SXDrive
//
//  Created by Skylable on 12/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYBaseView.h"

/**
* Delegate for handling view events.
*/
@protocol SKYLoginViewInteractionDelegate <NSObject>

/**
 * Called when user presses logo.
 */
- (void)userDidPressLogo;

/**
 * Called when user presses 'Login'.
 */
- (void)userDidPressLogIn;

@end

/**
 * Protocol of login view.
 */
@protocol SKYLoginView <SKYBaseView>

/**
 * The delegate for interaction events.
 */
@property (nonatomic, weak) id <SKYLoginViewInteractionDelegate> interactionDelegate;

@end

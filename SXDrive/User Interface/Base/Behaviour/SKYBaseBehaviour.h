//
//  SKYBaseBehaviour.h
//  SXDrive
//
//  Created by Skylable on 17/09/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

@import Foundation;

#import "SKYViewNavigator.h"

@class SKYItem;

/**
 * Presenter for the base behaviour.
 */
@protocol SKYBaseBehaviourPresenter <NSObject>

/**
 * Presenter's view controller.
 */
- (UIViewController *)viewControler;

@optional

/*
 * Shows alert indicating that public link is being generated.
 */
- (void)showPublicLinkGeneratingProgressPopup;

/*
 * Shows alert indicating that public link was generated and copied to clipboard or link generating process failed.
 * @param success
 */
- (void)showPublicLinkGeneratedPopup:(BOOL)success;

@end

/**
 * Protocol of base behaviour.
 */
@protocol SKYBaseBehaviour <NSObject>

/**
 * Presenter for the base behaviour.
 */
@property (nonatomic, weak) id <SKYBaseBehaviourPresenter> presenter;

/**
 * Injected view navigator.
 */
@property (nonatomic, weak) id <SKYViewNavigator> viewNavigator;

@required

/**
 * Called when user wants to generate public link for the item.
 * @param item Item to generate link.
 */
- (void)generatePublicLinkForItem:(SKYItem *)item;

@optional

/**
 * Starts the behaviour with optional info.
 * @param info Optional info to process.
 */
- (void)processInfo:(NSDictionary *)info;

@end

/**
 * Base class for all behaviours.
 */
@interface SKYBaseBehaviourImplementation : NSObject <SKYBaseBehaviour>

@end

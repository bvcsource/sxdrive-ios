//
//  SKYBaseController.h
//  SXDrive
//
//  Created by Skylable on 17/09/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

@import UIKit;

#import "SKYBaseBehaviour.h"
#import "SKYBaseView.h"

/**
 * Protocol of base controller.
 */
@protocol SKYBaseController <SKYBaseBehaviourPresenter>

/**
 * The info used during creation of controller.
 * Is passed to the behaviour when view finished loading.
 */
@property (nonatomic, strong) NSDictionary *info;

/**
 * Type of the view.
 */
@property (readonly) SKYViewType viewType;

/**
 * If YES the standard iOS interactive pop gesture will be enabled, if NO, not.
 * By default YES.
 */
@property (nonatomic) BOOL swipeToPopGestureEnabled;

/**
 * The view assigned to this controller.
 */
@optional
@property (nonatomic, strong, readonly) UIView <SKYBaseView> *baseView;

/**
 * The behaviour assigned to this controller.
 */
@property (nonatomic, strong, readonly) id <SKYBaseBehaviour> baseBehaviour;

@end

/**
 * Base class for all view controllers.
 */
@interface SKYBaseControllerImplementation : UIViewController <SKYBaseController>

/**
 * Base initializer for creating a view controller with the given view and behaviour.
 * @param baseView      View which the controller manages.
 * @param baseBehaviour Behaviour to use.
 * @return A base view controller.
 */
- (instancetype)initWithView:(UIView <SKYBaseView> *)baseView behaviour:(id <SKYBaseBehaviour>)baseBehaviour;

@end

@interface SKYBaseNibControllerImplementation : UIViewController <SKYBaseController>

/**
 * Base initializer for creating a view controller with the behaviour.
 * @param baseBehaviour Behaviour to use.
 * @return A base view controller.
 */

- (instancetype)initWithBehaviour:(id <SKYBaseBehaviour>)baseBehaviour;

@end

@interface SKYBaseTableControllerImplementation  : UITableViewController <SKYBaseController>

/**
 * Base initializer for creating a view controller with the given view and behaviour.
 * @param baseView      View which the controller manages.
 * @param baseBehaviour Behaviour to use.
 * @return A base view controller.
 */
- (instancetype)initWithView:(UITableView <SKYBaseView> *)baseView behaviour:(id <SKYBaseBehaviour>)baseBehaviour;

@end

@interface SKYBaseNibTableControllerImplementation  : UITableViewController <SKYBaseController>

/**
 * Base initializer for creating a view controller with the behaviour.
 * @param baseBehaviour Behaviour to use.
 * @return A base view controller.
 */
- (instancetype)initWithBehaviour:(id <SKYBaseBehaviour>)baseBehaviour;

@end

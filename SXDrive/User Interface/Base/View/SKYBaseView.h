//
//  SKYBaseView.h
//  SXDrive
//
//  Created by Skylable on 17/09/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

@import UIKit;

/**
 * Protocol of base view.
 */
@protocol SKYBaseView <NSObject>

@optional

/**
 * Creates all the subviews.
 */
- (void)createSubviews;

@end

/**
 * Base class for all views.
 */
@interface SKYBaseViewImplementation : UIView <SKYBaseView>

@end

/**
 * Protocol of base table view.
 */
@protocol SKYBaseTableView <SKYBaseView>

/**
 * Deselects selected cell.
 * @param animated YES if animated, NO otherwise.
 */
- (void)deselectSelectedCellAnimated:(BOOL)animated;

@end

/**
 * Base class for all table based views.
 */
@interface SKYBaseTableViewImplementation : UITableView <SKYBaseTableView>

@end

//
//  SKYBaseView.m
//  SXDrive
//
//  Created by Skylable on 17/09/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYBaseView.h"

@implementation SKYBaseViewImplementation

- (void)createSubviews
{
	
}

@end

@implementation SKYBaseTableViewImplementation

- (void)deselectSelectedCellAnimated:(BOOL)animated
{
	NSIndexPath *indexPath = [self indexPathForSelectedRow];
	
	if (indexPath != nil) {
		[self deselectRowAtIndexPath:indexPath animated:animated];
	}
}

@end

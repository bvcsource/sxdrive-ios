//
//  SKYAppearance.m
//  SXDrive
//
//  Created by Skylable on 04/11/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYAppearance.h"

#import "UIColor+SKYColor.h"
#import "UIFont+SKYFont.h"

@implementation SKYAppearance

+ (void)load
{
	[[UIToolbar appearance] setTranslucent:NO];
	[[UITabBar appearance] setTranslucent:NO];
	[[UITabBar appearance] setBarTintColor:[UIColor skyColorForTabBar]];
	[[UIActivityIndicatorView appearance] setColor:[UIColor skyMainColor]];
	[[UIStepper appearance] setTintColor:[UIColor skyMainColor]];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{
                                                           NSFontAttributeName: [UIFont fontForBarTexts]
                                                           }
                                                forState:UIControlStateNormal];
}

@end

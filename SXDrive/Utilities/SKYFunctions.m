//
//  SKYFunctions.m
//  SXDrive
//
//  Created by Skylable on 02/11/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYFunctions.h"

BOOL fEqual(float a, float b)
{
	return fabs(a - b) < FLT_EPSILON;
}

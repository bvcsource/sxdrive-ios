//
//  SKYFunctionsTests.m
//  SXDrive
//
//  Created by Skylable on 03/11/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYFunctions.h"

#import <Kiwi/Kiwi.h>

SPEC_BEGIN(SKYFunctionsTests)

describe(@"SKYFunctionsTests", ^{
	
	context(@"fEqual", ^{
		it(@"two floats should be equal test1", ^{
			BOOL result = fEqual(2.f, 2.f);
			[[theValue(result) should] beYes];
		});
		
		it(@"two floats should be equal test2", ^{
			BOOL result = fEqual(2.f, 2);
			[[theValue(result) should] beYes];
		});
		
		it(@"two floats should be equal test3", ^{
			BOOL result = fEqual(2.f, 2.f / 5.f * 5.f);
			[[theValue(result) should] beYes];
		});
		
		it(@"two different floats should not be equal", ^{
			BOOL result = fEqual(2.f, 3.f);
			[[theValue(result) should] beNo];
		});
	});
});

SPEC_END

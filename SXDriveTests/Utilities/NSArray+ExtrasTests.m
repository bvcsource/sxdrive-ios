//
//  NSArray+ExtrasTests.m
//  SXDrive
//
//  Created by Skylable on 15/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "NSArray+Extras.h"

#import <Kiwi/Kiwi.h>

SPEC_BEGIN(NSArray_ExtrasTests)

describe(@"NSArray_ExtrasTests", ^{
	
	context(@"randomObject", ^{
		it(@"should return nil for empty array", ^{
			[[[[NSArray array] randomObject] should] beNil];
		});
		
		it(@"should return random object", ^{
			NSArray *array = @[@"a", @"b"];
			
			NSObject *oneObject = [array randomObject];
			NSObject *secondObject = nil;
			for (int i = 0; i < 1000; i++) {
				secondObject = [array randomObject];
				
				if (secondObject != oneObject) {
					break;
				}
			}
			
			[[oneObject shouldNot] equal:secondObject];
		});
	});
	
	context(@"middleObjects", ^{
		it(@"should return nil for empty array", ^{
			[[[@[] middleObjects] should] beNil];
		});
		
		it(@"should return equal array for single item array", ^{
			id dummyObject = [KWMock mock];
			id dummyArray = @[dummyObject];
			
			NSArray *result = [dummyArray middleObjects];
			[[result should] equal:@[dummyObject]];
		});
		
		it(@"should return equal array for two item array", ^{
			id dummyObject1 = [KWMock mock];
			id dummyObject2 = [KWMock mock];
			id dummyArray = @[dummyObject1, dummyObject2];
			
			NSArray *result = [dummyArray middleObjects];
			[[result should] equal:@[dummyObject1, dummyObject2]];
		});
		
		it(@"should return array with middle object for array with odd number of items (test1)", ^{
			id dummyObject1 = [KWMock mock];
			id dummyObject2 = [KWMock mock];
			id dummyObject3 = [KWMock mock];
			
			id dummyArray = @[dummyObject1, dummyObject2, dummyObject3];
			NSArray *result = [dummyArray middleObjects];
			[[result should] equal:@[dummyObject2]];
		});
		
		it(@"should return array with middle object for array with odd number of items (test2)", ^{
			id dummyObject1 = [KWMock mock];
			id dummyObject2 = [KWMock mock];
			id dummyObject3 = [KWMock mock];
			id dummyObject4 = [KWMock mock];
			id dummyObject5 = [KWMock mock];
			id dummyArray = @[dummyObject1, dummyObject2, dummyObject3, dummyObject4, dummyObject5];
			
			NSArray *result = [dummyArray middleObjects];
			[[result should] equal:@[dummyObject3]];
		});
		
		it(@"should return array with two middle objects for array with even number of items (test1)", ^{
			id dummyObject1 = [KWMock mock];
			id dummyObject2 = [KWMock mock];
			id dummyObject3 = [KWMock mock];
			id dummyObject4 = [KWMock mock];
			
			id dummyArray = @[dummyObject1, dummyObject2, dummyObject3, dummyObject4];
			NSArray *result = [dummyArray middleObjects];
			[[result should] equal:@[dummyObject2, dummyObject3]];
		});
		
		it(@"should return array with two middle objects for array with even number of items (test2)", ^{
			id dummyObject1 = [KWMock mock];
			id dummyObject2 = [KWMock mock];
			id dummyObject3 = [KWMock mock];
			id dummyObject4 = [KWMock mock];
			id dummyObject5 = [KWMock mock];
			id dummyObject6 = [KWMock mock];
			id dummyArray = @[dummyObject1, dummyObject2, dummyObject3, dummyObject4, dummyObject5, dummyObject6];
			
			NSArray *result = [dummyArray middleObjects];
			[[result should] equal:@[dummyObject3, dummyObject4]];
		});
	});
});

SPEC_END

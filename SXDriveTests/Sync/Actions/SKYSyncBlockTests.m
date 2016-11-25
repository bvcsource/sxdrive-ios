//
//  SKYSyncBlockTests.m
//  SXDrive
//
//  Created by Skylable on 27/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYSyncBlock.h"

#import <Kiwi/Kiwi.h>

@interface SKYSyncBlock (TESTS)

@property (nonatomic, strong) NSString *blockName;
@property (nonatomic, strong) NSArray *nodes;
@property (nonatomic, strong) NSMutableArray *unavailableNodes;
- (NSArray *)availableNodes;

@end

SPEC_BEGIN(SKYSyncBlockTests)

describe(@"SKYSyncBlockTests", ^{
	__block SKYSyncBlock *systemUnderTest;
	
	beforeEach(^{
		systemUnderTest = [[SKYSyncBlock alloc] initWithBlockName:@"dummy-block-name" nodes:@[@"dummy-node-1", @"dummy-node-2"]];
	});
	
	context(@"when initialized", ^{
		it(@"should save the name and the nodes", ^{
			[[systemUnderTest.blockName should] equal:@"dummy-block-name"];
			[[systemUnderTest.nodes should] equal:@[@"dummy-node-1", @"dummy-node-2"]];
		});
	});
	
	context(@"unavailableNodes", ^{
		it(@"should return a mutable array", ^{
			[[[systemUnderTest unavailableNodes] should] beKindOfClass:[NSMutableArray class]];
		});
	});
	
	context(@"available nodes", ^{
		it(@"should return only available nodes", ^{
			id mockNode1 = [KWMock mock];
			id mockNode2 = [KWMock mock];
			id mockNode3 = [KWMock mock];
			
			systemUnderTest.nodes = @[mockNode1, mockNode2, mockNode3];
			systemUnderTest.unavailableNodes = [NSMutableArray arrayWithObject:mockNode2];
			
			[[[systemUnderTest availableNodes] should] equal:@[mockNode1, mockNode3]];
		});
	});
	
	context(@"randomNode", ^{
		context(@"and there are available nodes", ^{
			it(@"should return random available node", ^{
				id mockNode1 = [KWMock mock];
				id mockNode2 = [KWMock mock];
				[[systemUnderTest should] receive:@selector(availableNodes) andReturn:@[mockNode1, mockNode2] withCountAtLeast:2];
				
				BOOL receivedNode1 = NO;
				BOOL receivedNode2 = NO;
				
				for (int i = 0; i < 100; i++) {
					id randomNode = [systemUnderTest randomNode];
					
					if (randomNode == mockNode1) {
						receivedNode1 = YES;
					}
					else if (randomNode == mockNode2) {
						receivedNode2 = YES;
					}
					
					if (receivedNode1 == YES && receivedNode2 == YES) {
						break;
					}
				}
				
				[[theValue(receivedNode1 && receivedNode2) should] beYes];
			});
		});
		context(@"and there is no available nodes", ^{
			it(@"should return nil", ^{
				[[systemUnderTest should] receive:@selector(availableNodes) andReturn:@[]];
				
				[[[systemUnderTest randomNode] should] beNil];
			});
		});
		
		context(@"mark node as unavailable", ^{
			it(@"should save it to unavailable nodes array", ^{
				id mockArray = [KWMock mockForClass:[NSMutableArray class]];
				[[systemUnderTest should] receive:@selector(unavailableNodes) andReturn:mockArray];
				
				[[mockArray should] receive:@selector(addObject:) withArguments:@"dummy-node"];
				[systemUnderTest markNodeAsUnavailable:@"dummy-node"];
			});
		});
	});
});

SPEC_END

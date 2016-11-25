//
//  SKYSyncBlock.m
//  SXDrive
//
//  Created by Skylable on 26/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYSyncBlock.h"

#import "NSArray+Extras.h"

@interface SKYSyncBlock ()

/**
 * Property redeclaration to have write access.
 */
@property (nonatomic, strong) NSString *blockName;

/**
 * Property redeclaration to have write access.
 */
@property (nonatomic, strong) NSArray *nodes;

/**
 * Keeps nodes which has been marked as unavailable.
 */
@property (nonatomic, strong) NSMutableArray *unavailableNodes;

/**
 * Helper method which returns nodes-unavailable nodes.
 * @return Available nodes or empty array.
 */
- (NSArray *)availableNodes;

@end

@implementation SKYSyncBlock

- (instancetype)initWithBlockName:(NSString *)blockName nodes:(NSArray *)nodes
{
	self = [super init];
	
	if (self) {
		_blockName = blockName;
		_nodes = nodes;
	}
	
	return self;
}

+ (NSArray *)syncBlocksWithSerializedArray:(NSArray *)array
{
	NSMutableArray *syncBlocks = [NSMutableArray array];
	
	for (int i = 0; i < array.count; i++) {
		NSDictionary *serializedBlock = array[i];
		
		NSString *blockName = [serializedBlock allKeys][0];
		NSArray *nodes = serializedBlock[blockName];
		
		SKYSyncBlock *syncBlock = [[SKYSyncBlock alloc] initWithBlockName:blockName nodes:nodes];
		syncBlock.blockIndex = syncBlocks.count;
		[syncBlocks addObject:syncBlock];
	}
	
	return syncBlocks.copy;
}

+ (NSArray *)syncBlocksWithSerializedDictionary:(NSDictionary *)dictionary
{
	NSMutableArray *syncBlocks = [NSMutableArray array];
	
	for (NSString *key in dictionary) {
		NSArray *nodes = dictionary[key];
		
		SKYSyncBlock *syncBlock = [[SKYSyncBlock alloc] initWithBlockName:key nodes:nodes];
		[syncBlocks addObject:syncBlock];
	}
	
	return syncBlocks.copy;
}

- (NSMutableArray *)unavailableNodes
{
	if (_unavailableNodes == nil) {
		_unavailableNodes = [NSMutableArray array];
	}
	
	return _unavailableNodes;
}

- (NSArray *)availableNodes
{
	NSMutableArray *availableNodes = [NSMutableArray arrayWithArray:self.nodes];
	
	for (NSString *unavailableNode in self.unavailableNodes) {
		[availableNodes removeObject:unavailableNode];
	}
	
	return availableNodes;
}

- (NSString *)randomNode
{
	NSArray *availableNodes = self.availableNodes;
	if (availableNodes.count > 0) {
		return availableNodes.randomObject;
	}
	else {
		return nil;
	}
}

- (void)markNodeAsUnavailable:(NSString *)node
{
	[self.unavailableNodes addObject:node];
}

@end

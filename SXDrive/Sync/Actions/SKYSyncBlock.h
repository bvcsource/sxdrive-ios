//
//  SKYSyncBlock.h
//  SXDrive
//
//  Created by Skylable on 26/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

@import Foundation;

/**
 * Block (for upload or download sync actions).
 */
@interface SKYSyncBlock : NSObject

/**
 * Name of the block.
 */
@property (nonatomic, readonly) NSString *blockName;

/**
 * Block destination/source nodes.
 */
@property (nonatomic, readonly) NSArray *nodes;

/**
 * Index of block.
 */
@property (nonatomic) NSUInteger blockIndex;

/**
 * Initializes the sync block object.
 * @param blockName Block name.
 * @param nodes     Nodes.
 * @return Initialized sync block object.
 */
- (instancetype)initWithBlockName:(NSString *)blockName nodes:(NSArray *)nodes;

/**
 * Generates sync block objects based on the array from cloud response.
 * @note It sets blockIndex of sync blocks according to the order in the array.
 * @param array Array with serialized block objects.
 * @return Array with sync block objects.
 */
+ (NSArray *)syncBlocksWithSerializedArray:(NSArray *)array;

/**
 * Generates sync block objects based on the dictionary from cloud response.
 * It doesn't set block index of blocks as dictionary doesn't have order.
 * @param dictionary Dictionary with serialized block objects.
 * @return Array with sync block objects.
 */
+ (NSArray *)syncBlocksWithSerializedDictionary:(NSDictionary *)dictionary;

/**
 * Preferred method to return one of the nodes, because it skips unavailable nodes.
 * @return Random available node or nil.
 */
- (NSString *)randomNode;

/**
 * Called when using this node caused error, marks it as unavailable, and random node will never return it again.
 * @param node Node to mark as unavailable.
 */
- (void)markNodeAsUnavailable:(NSString *)node;

@end

//
//  SKYGeneratePublicLinkAction.h
//  SXDrive
//
//  Created by Skylable on 6/12/15.
//  Copyright (c) 2015 Skylable. All rights reserved.
//

#import "SKYSyncAction.h"

/**
 * Action responsible for generating public link to files.
 */
@interface SKYSyncGeneratePublicLinkAction : SKYSyncAction

/**
 * Creates generate public link action with given item.
 * @param item Item (file) to use to create public link.
 * @return Initialized SKYSyncGeneratePublicLinkAction.
 */
+ (instancetype)actionWithItem:(SKYItem *)item;

@end

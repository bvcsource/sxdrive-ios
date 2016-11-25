//
//  SKYNodeManager.h
//  SXDrive
//
//  Created by Skylable on 06/01/15.
//  Copyright (c) 2015 Skylable. All rights reserved.
//

@import Foundation;

@interface SKYNodeManager : NSObject

+ (NSArray *)nodesForVolume:(NSString *)volumeName;

+ (void)setNodes:(NSArray *)nodes forVolume:(NSString *)volumeName;

@end

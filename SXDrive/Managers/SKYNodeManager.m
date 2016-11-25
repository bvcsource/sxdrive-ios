//
//  SKYNodeManager.m
//  SXDrive
//
//  Created by Skylable on 06/01/15.
//  Copyright (c) 2015 Skylable. All rights reserved.
//

#import "SKYNodeManager.h"

#import "NSString+Extras.h"

@implementation SKYNodeManager

+ (NSString *)processVolumeNameForPath:(NSString *)volume {
    NSString *volumeName = nil;
    NSArray *pathComponents = [[volume hasPrefix:@"/"] ? [volume substringFromIndex:1]:volume componentsSeparatedByString:@"/"];
	if (pathComponents.count > 0) {
		volumeName = pathComponents[0];
	}
	else {
		volumeName = volume;
	}
	
	return [NSString stringWithFormat:@"SKYVolumes_%@", [volumeName SHA1]];
}

+ (NSArray *)nodesForVolume:(NSString *)volumeName {
    NSString *key = [self processVolumeNameForPath:volumeName];
	return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

+ (void)setNodes:(NSArray *)nodes forVolume:(NSString *)volumeName {
    NSString *key = [self processVolumeNameForPath:volumeName];
	[[NSUserDefaults standardUserDefaults] setObject:nodes forKey:key];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

@end

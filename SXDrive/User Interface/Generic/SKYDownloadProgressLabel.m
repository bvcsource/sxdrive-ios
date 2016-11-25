//
//  SKYDownloadProgressLabel.m
//  SXDrive
//
//  Created by Skylable on 10/01/15.
//  Copyright (c) 2015 Skylable. All rights reserved.
//

#import "SKYDownloadProgressLabel.h"

#import "SKYAppInjector.h"
#import "SKYInfoKeys.h"
#import "SKYFunctions.h"
#import "SKYNotificationNames.h"
#import "SKYPersistence.h"

@interface SKYDownloadProgressLabel ()

@property (nonatomic, strong) id <SKYPersistence> persistence;

- (void)processProgress:(float)progress;

@end

@implementation SKYDownloadProgressLabel

- (instancetype)init
{
	self = [super init];
	
	if (self) {
		_persistence = [SKYAppInjector injectObjectForProtocol:@protocol(SKYPersistence)];
		
		__weak typeof(self) weakSelf = self;
		[[NSNotificationCenter defaultCenter] addObserverForName:SKYMajorFileStructureDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
			if (_item != nil && [self.persistence isItemDownloaded:_item] == YES) {
				[weakSelf processProgress:1.f];
			}
			else {
				[weakSelf processProgress:[_persistence downloadProgressForItem:_item]];
			}
		}];
	}
	
	return self;
}

- (void)setItem:(SKYItem *)item
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:SKYDownloadProgressDidChangeNotification object:nil];
	_item = item;
	
	if ([self.persistence isItemDownloaded:item] == YES) {
		[self processProgress:1.f];
	}
	else {
		[self processProgress:[self.persistence downloadProgressForItem:self.item]];
	}
	
	__weak typeof(self) weakSelf = self;
	[[NSNotificationCenter defaultCenter] addObserverForName:SKYDownloadProgressDidChangeNotification object:item queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
		
		float percent = [note.userInfo[SKYInfoKeyForDownloadProgress] floatValue];
		
		[weakSelf processProgress:percent];
	}];
}

- (void)processProgress:(float)progress
{
	if (fEqual(progress, 0.f)) {
		if (self.displayProgressForZero == YES) {
			self.text = @"0%";
		}
		else {
			self.text = @"";
		}
	}
	else if (fEqual(progress, 1.f)) {
		self.text = @"✓";
	}
	else {
		self.text = [NSString stringWithFormat:@"%.0f%%", progress * 100];
	}
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

//
//  SKYSingleFileViewWebView.m
//  SXDrive
//
//  Created by Skylable on 05/11/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYSingleFileViewWebView.h"

@implementation SKYSingleFileViewWebView

- (instancetype)init
{
	self = [super init];
	
	if (self) {
		self.scalesPageToFit = YES;
		self.multipleTouchEnabled = YES;
	}
	
	return self;
}

- (void)loadURL:(NSURL *)url
{
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	[self loadRequest:request];
}

@end

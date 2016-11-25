//
//  SKYSingleFileController.m
//  SXDrive
//
//  Created by Skylable on 15/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYSingleFileController.h"

#import "NSByteCountFormatter+Extras.h"
#import "SKYItem.h"
#import "NSDateFormatter+Extras.h"
#import "NSFileManager+Extras.h"

@interface SKYSingleFileController ()

/**
 * Property for accessing the single file view.
 */
@property (weak, nonatomic, readonly) UIView <SKYSingleFileView> *singleFileView;

/**
 * Property for accessing the single file behaviour.
 */
@property (weak, nonatomic, readonly) id <SKYSingleFileBehaviour> singleFileBehaviour;

@end

@implementation SKYSingleFileController

- (instancetype)initWithSingleFileView:(UIView<SKYSingleFileView> *)singleFileView singleFileBehaviour:(id<SKYSingleFileBehaviour>)singleFileBehaviour
{
	self = [super initWithView:singleFileView behaviour:singleFileBehaviour];
	
	if (self) {

	}
	
	return self;
}

- (SKYViewType)viewType
{
	return SKYViewTypeSingleFile;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
}

#pragma mark - Convenience accessors

- (UIView <SKYSingleFileView> *)singleFileView
{
	return (UIView <SKYSingleFileView> *)self.baseView;
}

- (id <SKYSingleFileBehaviour>)singleFileBehaviour
{
	return (id <SKYSingleFileBehaviour>)self.baseBehaviour;
}

#pragma mark - SKYSingleFileBehaviourPresenter

- (void)displayBeforeViewForItem:(SKYItem *)item
{
	NSString *size = [NSByteCountFormatter skyStringWithByteCount:item.fileSize.unsignedLongLongValue];
	NSString *date = [[NSDateFormatter dateFormatterForLastModificationDate] stringFromDate:item.updateDate];
	[self.singleFileView configureWithFileName:item.name fileSize:size modificationDate:date];
}

- (void)displayProgress:(float)progress
{
	[self.singleFileView setProgress:progress];
}

- (void)displayFileContentsAtPath:(NSString *)path
{
	if ([NSFileManager isFileOfImageType:path] == YES) {
		UIImage *image = [UIImage imageWithContentsOfFile:path];
		[self.singleFileView displayImage:image];
	}
	else if ([NSFileManager isFileOfMovieType:path] == YES || [NSFileManager isFileOfMusicType:path] == YES) {
		[self.singleFileView displayPlayMediaButtonWithURL:[NSURL fileURLWithPath:path]];
		//[self.singleFileView displayFileInMovieViewWithURL:[NSURL fileURLWithPath:path]];
	}
	else {
		[self.singleFileView displayFileInWebViewWithURL:[NSURL fileURLWithPath:path]];
	}
}

@end

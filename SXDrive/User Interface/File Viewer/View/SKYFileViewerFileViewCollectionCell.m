//
//  SKYFileViewerFileViewCollectionCell.m
//  SXDrive
//
//  Created by Skylable on 15/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYFileViewerFileViewCollectionCell.h"

/**
 * Reuse identifier for SKYFileViewerFileViewCollectionCell.
 */
NSString * const SKYFileViewerFileViewCollectionCellReuseIdentifier = @"SKYFileViewerFileViewCollectionCellReuseIdentifier";

@interface SKYFileViewerFileViewCollectionCell ()

@property (nonatomic, strong) UIView *fileView;

@end

@implementation SKYFileViewerFileViewCollectionCell

- (void)prepareForReuse
{
	[super prepareForReuse];
	
	if (self.fileView != nil) {
		[self.interactionDelegate userScrolledFileViewBeyondVisibleArea:self.fileView];
		[self.fileView removeFromSuperview];
	}
}

- (void)displayFileView:(UIView *)fileView;
{
	self.fileView = fileView;
	
	self.fileView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.contentView addSubview:self.fileView];
	[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": self.fileView}]];
	[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view": self.fileView}]];
}

@end

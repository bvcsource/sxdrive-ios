//
//  SKYSingleFileViewImageView.m
//  SXDrive
//
//  Created by Skylable on 05/11/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYSingleFileViewImageView.h"

@interface SKYSingleFileViewImageView () <UIScrollViewDelegate>

/**
 * Image view.
 */
@property (nonatomic, strong) UIImageView *imageView;

/**
 * Create subviews.
 */
- (void)createSubviews;

/**
 * Keeps in memory what bounds size has been in use when the scale was adjusted.
 */
@property (nonatomic) CGSize adjustedToSize;

@end

@implementation SKYSingleFileViewImageView

- (instancetype)init
{
	self = [super init];
	
	if (self) {
		self.delegate = self;
		[self createSubviews];
	}
	
	return self;
}

- (void)createSubviews
{
	self.backgroundColor = [UIColor whiteColor];
	
	_imageView = [UIImageView new];
	_imageView.translatesAutoresizingMaskIntoConstraints = NO;
	[self addSubview:_imageView];
}

- (void)displayImage:(UIImage *)image
{
	self.adjustedToSize = CGSizeZero;
	self.imageView.image = image;
	self.contentSize = image.size;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	if (CGSizeEqualToSize(self.bounds.size, self.adjustedToSize) == NO) {
		self.adjustedToSize = self.bounds.size;
		
		CGFloat xScale = self.bounds.size.width / self.imageView.image.size.width;
		CGFloat yScale = self.bounds.size.height / self.imageView.image.size.height;
		CGFloat minScale = MIN(xScale, yScale);
		
		self.minimumZoomScale = minScale;
		self.maximumZoomScale = 1.f;
		self.zoomScale = minScale;
	}
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return self.imageView;
}

// Empty implementation yet method required for zooming according to the documentation.
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
	
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
	CGSize imgViewSize = self.imageView.frame.size;
	CGSize imageSize = self.imageView.image.size;
	
	CGSize realImgSize;
	if (imageSize.width / imageSize.height > imgViewSize.width / imgViewSize.height) {
		realImgSize = CGSizeMake(imgViewSize.width, imgViewSize.width / imageSize.width * imageSize.height);
	}
	else {
		realImgSize = CGSizeMake(imgViewSize.height / imageSize.height * imageSize.width, imgViewSize.height);
	}
	
	CGRect fr = CGRectMake(0, 0, 0, 0);
	fr.size = realImgSize;
	self.imageView.frame = fr;
	
	CGSize scrSize = scrollView.frame.size;
	float offx = (scrSize.width > realImgSize.width ? (scrSize.width - realImgSize.width) / 2 : 0);
	float offy = (scrSize.height > realImgSize.height ? (scrSize.height - realImgSize.height) / 2 : 0);
	
	scrollView.contentInset = UIEdgeInsetsMake(offy, offx, offy, offx);
}

@end

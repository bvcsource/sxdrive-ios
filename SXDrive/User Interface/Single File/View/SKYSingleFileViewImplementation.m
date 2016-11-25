//
//  SKYSingleFileViewImplementation.m
//  SXDrive
//
//  Created by Skylable on 15/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYSingleFileViewImplementation.h"

#import "SKYFunctions.h"
#import "SKYNotificationNames.h"
#import "SKYSingleFileViewImageView.h"
#import "SKYSingleFileViewMovieView.h"
#import "SKYSingleFileViewWebView.h"
#import "UIColor+SKYColor.h"
#import "UIFont+SKYFont.h"
#import "UIImage+SKYImage.h"

/**
 * Minimum distance between side edges and texts.
 */
static CGFloat const SKYSingleFileViewMinimumDistanceBetweedSideEdgesAndTexts = 20.f;

/**
 * Distance between logo and filename.
 */
static CGFloat const SKYSingleFileViewDistanceBetweenLogoAndFilename = 15.f;

@interface SKYSingleFileViewImplementation ()

/**
 * Play media button.
 */
@property (nonatomic, strong) UIButton *playMediaButton;

/**
 * Main subview - either loading subview or subview for different types of file to present.
 */
@property (nonatomic, strong) UIView *mainSubview;

/**
 * File icon.
 */
@property (nonatomic, strong) UIImageView *fileIcon;

/**
 * File name label.
 */
@property (nonatomic, strong) UILabel *fileNameLabel;

/**
 * File info label.
 */
@property (nonatomic, strong) UILabel *fileInfoLabel;

/**
 * Progress bar presenting the download progress of the file.
 */
@property (nonatomic, strong) UIProgressView *progressBar;

/**
 * URL for media file.
 */
@property (nonatomic, strong) NSURL *mediaURL;

/**
 * Called when media button was pressed
 */
- (void)playMediaButtonDidPress;

@end

@implementation SKYSingleFileViewImplementation

@synthesize interactionDelegate = _interactionDelegate;

- (void)createSubviews
{
	self.backgroundColor = [UIColor whiteColor];
	
	self.fileIcon = [UIImageView new];
	self.fileIcon.translatesAutoresizingMaskIntoConstraints = NO;
	[self addSubview:self.fileIcon];
	
	[self addConstraint:[NSLayoutConstraint constraintWithItem:self.fileIcon attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
	
	self.fileNameLabel = [UILabel new];
	self.fileNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
	self.fileNameLabel.textAlignment = NSTextAlignmentCenter;
	self.fileNameLabel.numberOfLines = 0;
	self.fileNameLabel.preferredMaxLayoutWidth = [UIScreen mainScreen].bounds.size.width - SKYSingleFileViewMinimumDistanceBetweedSideEdgesAndTexts * 2;
	self.fileNameLabel.font = [UIFont fontForFilenameLabelOnFileViewer];
	[self addSubview:self.fileNameLabel];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:self.fileNameLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
	
	UIView *spacer1 = [UIView new];
	spacer1.translatesAutoresizingMaskIntoConstraints = NO;
	[self addSubview:spacer1];
	UIView *spacer2 = [UIView new];
	spacer2.translatesAutoresizingMaskIntoConstraints = NO;
	[self addSubview:spacer2];
	
	NSDictionary *metrics = @{@"distance": @(SKYSingleFileViewDistanceBetweenLogoAndFilename)};
	NSDictionary *views = @{@"spacer1": spacer1, @"spacer2": spacer2, @"icon": self.fileIcon, @"nameLabel": self.fileNameLabel};
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[spacer1(>=0)][icon]-(distance)-[nameLabel][spacer2(==spacer1)]|" options:0 metrics:metrics views:views]];
	
	self.fileInfoLabel = [UILabel new];
	self.fileInfoLabel.translatesAutoresizingMaskIntoConstraints = NO;
	self.fileInfoLabel.textAlignment = NSTextAlignmentCenter;
	self.fileInfoLabel.numberOfLines = 2;
	self.fileInfoLabel.font = [UIFont fontForFileDetailsLabelOnFileViewer];
	self.fileInfoLabel.textColor = [UIColor skyColorForFileInfo];
	[self addSubview:self.fileInfoLabel];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:self.fileInfoLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:self.fileInfoLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.fileNameLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:2.f]];

	self.playMediaButton = [UIButton buttonWithType:UIButtonTypeSystem];
	self.playMediaButton.translatesAutoresizingMaskIntoConstraints = NO;
	self.playMediaButton.alpha = 0.f;
	self.playMediaButton.titleLabel.font = [UIFont fontForPlayMediaButtonOnFileViewer];
	[self.playMediaButton addTarget:self action:@selector(playMediaButtonDidPress) forControlEvents:UIControlEventTouchUpInside];
	NSString *playMediaButtonTitle = NSLocalizedString(@"Play media", @"Button title to play audio or video.");
	[self.playMediaButton setTitle:playMediaButtonTitle forState:UIControlStateNormal];
	[self addSubview:self.playMediaButton];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:self.playMediaButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:self.playMediaButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.fileInfoLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:2.f]];

	
	self.progressBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
	self.progressBar.translatesAutoresizingMaskIntoConstraints = NO;
	self.progressBar.alpha = 0.f;
	[self addSubview:self.progressBar];
	
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[bar]-|" options:0 metrics:nil views:@{@"bar": self.progressBar}]];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:self.progressBar attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:-20]];
}

- (void)configureWithFileName:(NSString *)fileName fileSize:(NSString *)fileSize modificationDate:(NSString *)modificationDate
{
	self.fileNameLabel.text = fileName;
	self.fileIcon.image = [UIImage iconImageForFileWithName:fileName largeIcon:YES];
	self.fileInfoLabel.text = [NSString stringWithFormat:@"%@\n%@", fileSize, modificationDate];
}

- (void)setProgress:(float)progress
{
	self.progressBar.progress = progress;

	if (fEqual(progress, 1.f)) {
		[UIView animateWithDuration:0.3 delay:0.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
			self.progressBar.alpha = 0.f;
		} completion:nil];
	}
	else {
		self.progressBar.alpha = 1.f;
		
		if (self.mainSubview != nil) {
			[self.mainSubview removeFromSuperview];
			self.mainSubview = nil;
		}
	}
}

- (void)displayFileInWebViewWithURL:(NSURL *)url
{
	if ([self.mainSubview isKindOfClass:[SKYSingleFileViewWebView class]] == NO) {
		[self.mainSubview removeFromSuperview];
		self.mainSubview = nil;
		
		SKYSingleFileViewWebView *webView = [SKYSingleFileViewWebView new];
		webView.translatesAutoresizingMaskIntoConstraints = NO;
		[self addSubview:webView];
		self.mainSubview = webView;
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": webView}]];
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view": webView}]];
	}
	
	[(SKYSingleFileViewWebView *)self.mainSubview loadURL:url];
}

- (void)displayFileInMovieViewWithURL:(NSURL *)url
{
	if ([self.mainSubview isKindOfClass:[SKYSingleFileViewMovieView class]] == NO) {
		[self.mainSubview removeFromSuperview];
		self.mainSubview = nil;
		
		SKYSingleFileViewMovieView *moviewView = [SKYSingleFileViewMovieView new];
		moviewView.translatesAutoresizingMaskIntoConstraints = NO;
		[self addSubview:moviewView];
		self.mainSubview = moviewView;
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": moviewView}]];
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view": moviewView}]];
	}
	
	[(SKYSingleFileViewWebView *)self.mainSubview loadURL:url];
}

- (void)displayPlayMediaButtonWithURL:(NSURL *)url
{
	self.mediaURL = url;
	[UIView animateWithDuration:0.3 animations:^{
		self.playMediaButton.alpha = 1.f;
	}];
}

- (void)playMediaButtonDidPress
{
	[[NSNotificationCenter defaultCenter] postNotificationName:SKYPlayMediaInExternalVCNotification object:self.mediaURL];
}

- (void)displayImage:(UIImage *)image
{
	if ([self.mainSubview isKindOfClass:[SKYSingleFileViewImageView class]] == NO) {
		[self.mainSubview removeFromSuperview];
		self.mainSubview = nil;
		
		SKYSingleFileViewImageView *imageView = [SKYSingleFileViewImageView new];
		imageView.translatesAutoresizingMaskIntoConstraints = NO;
		[self addSubview:imageView];
		self.mainSubview = imageView;
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": imageView}]];
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view": imageView}]];
	}
	

	[(SKYSingleFileViewImageView *)self.mainSubview displayImage:image];
}

@end

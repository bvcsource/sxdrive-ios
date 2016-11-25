//
//  SKYSingleFileViewMovieView.m
//  SXDrive
//
//  Created by Skylable on 23/12/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

@import MediaPlayer;

#import "SKYSingleFileViewMovieView.h"

@interface SKYSingleFileViewMovieView ()

@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;

@end

@implementation SKYSingleFileViewMovieView

- (void)setMoviePlayer:(MPMoviePlayerController *)moviePlayer
{
	if (_moviePlayer != nil) {
		[self.moviePlayer.view removeFromSuperview];
	}
	
	_moviePlayer = moviePlayer;
}

- (void)loadURL:(NSURL *)url
{
	self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
	
	[self.moviePlayer setScalingMode:MPMovieScalingModeAspectFit];
	[self.moviePlayer setShouldAutoplay:NO];
	
	[self.moviePlayer setMovieSourceType:MPMovieSourceTypeFile];
	self.moviePlayer.view.frame = self.frame;
	self.moviePlayer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.moviePlayer setRepeatMode:MPMovieRepeatModeNone];

	[self addSubview:self.moviePlayer.view];
	[self.moviePlayer prepareToPlay];
}

@end

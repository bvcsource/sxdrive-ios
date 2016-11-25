//
//  SKYSingleFileView.h
//  SXDrive
//
//  Created by Skylable on 15/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYBaseView.h"

/**
 * Delegate for handling view events.
 */
@protocol SKYSingleFileViewInteractionDelegate <NSObject>

@end

/**
 * Protocol of single file view.
 */
@protocol SKYSingleFileView <SKYBaseView>

/**
 * The delegate for interaction events.
 */
@property (nonatomic, weak) id <SKYSingleFileViewInteractionDelegate> interactionDelegate;

/**
 * Configures the view.
 * @param fileName         Filename.
 * @param fileSize         File size.
 * @param modificationDate Modification date.
 */
- (void)configureWithFileName:(NSString *)fileName fileSize:(NSString *)fileSize modificationDate:(NSString *)modificationDate;

/**
 * Sets progress on the progress bar.
 * @param progress Progress.
 */
- (void)setProgress:(float)progress;

/**
 * Shows the file in the browser.
 * @param url Local URL to the file.
 */
- (void)displayFileInWebViewWithURL:(NSURL *)url;

/**
 * Shows the file in moview view.
 * @param url Local URL to the file.
 */
- (void)displayFileInMovieViewWithURL:(NSURL *)url;

/**
 * Displays play media button.
 */
- (void)displayPlayMediaButtonWithURL:(NSURL *)url;

/**
 * Shows the image.
 * @param image Image to show.
 */
- (void)displayImage:(UIImage *)image;

@end

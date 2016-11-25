//
//  SKYSingleFileViewMovieView.h
//  SXDrive
//
//  Created by Skylable on 23/12/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

@import UIKit;

/**
 * Subview presenting movies.
 * @note This class can be also used for music.
 */
@interface SKYSingleFileViewMovieView : UIView

/**
 * Loads given URL for the local movie file.
 * @param url URL of the local movie file.
 */
- (void)loadURL:(NSURL *)url;

@end

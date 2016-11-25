//
//  SKYSingleFileViewWebView.h
//  SXDrive
//
//  Created by Skylable on 05/11/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

@import UIKit;

/**
 * Subview presenting content that can be shown in the browser.
 */
@interface SKYSingleFileViewWebView : UIWebView

/**
 * Loads given URL of the local file.
 * @param url URL of the local file.
 */
- (void)loadURL:(NSURL *)url;

@end

//
//  SKYDownloadProgressLabel.h
//  SXDrive
//
//  Created by Skylable on 10/01/15.
//  Copyright (c) 2015 Skylable. All rights reserved.
//

@import UIKit;

@class SKYItem;

@interface SKYDownloadProgressLabel : UILabel

/**
 * Displays text even when progress is 0%, otherwise it has to be > 0%.
 * @note Should be assigned before item property.
 */
@property (nonatomic) BOOL displayProgressForZero;

@property (nonatomic, strong) SKYItem *item;

@end

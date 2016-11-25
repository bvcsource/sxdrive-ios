//
//  SKYImportFileBehaviour.h
//  SXDrive
//
//  Created by Skylable on 5/6/15.
//  Copyright (c) 2015 Skylable. All rights reserved.
//

@import Foundation;

#import "SKYBaseBehaviour.h"
#import "SKYItem.h"
#import "SKYPersistence.h"

/**
 * Presenter for the import file behaviour.
 */
@protocol SKYImportFileBehaviourPresenter <SKYBaseBehaviourPresenter>

/**
 * Contains source url of file to import.
 */
@property (nonatomic, strong) NSString *fileSourceURL;

/**
 * Contains name of file to import.
 */
@property (nonatomic, strong) NSString *fileName;

/**
 * Contains extension of file to import.
 */
@property (nonatomic, strong) NSString *fileExtension;

/**
 * Honds an array of SKYItem object that define a current directory to import file.
 */
@property (nonatomic, strong) NSArray *currentItems;

/**
 * Honds an array of SKYItem object that define a new directory to import file.
 * Current directory is replaced with a new directory as soon as user taps 'Choose' button.
 */
@property (nonatomic, strong) NSMutableArray *updatedItems;

/**
 * Adds SKYItem to directory path while choosing directory to import file.
 * Update directory path, if needed.
 */
- (void)updateImportFileDirectory:(SKYItem *)item;

/**
 * Called when user presses choose directory button in navigation bar.
 */
- (void)userDidChooseDirectory;

/**
 * Called when user presses cancel button in toolbar while choosing directory.
 */
- (void)userDidCancelChoosingDirectory;

@end

/**
 * Protocol of import file behaviour.
 */
@protocol SKYImportFileBehaviour <SKYBaseBehaviour>

/**
 * Presenter for the import file behaviour.
 */
@property (nonatomic, weak) id <SKYImportFileBehaviourPresenter> presenter;

/**
 * Persistence.
 */
@property (nonatomic, strong) id <SKYPersistence> persistence;

/**
 * Choose a different directory to import file.
 */
- (void)chooseDifferentDirectory;

/**
 * Imports file at a specified directory.
 * @param file    Dictionary that contains file info.
 * @param items   An array of SKYItem objects.
 */
- (void)saveFile:(NSDictionary *)file atDirectory:(NSArray *)items;

/**
 * Cancels import file.
 */
- (void)cancelImportFile;

@end

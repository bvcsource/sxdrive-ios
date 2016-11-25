//
//  SKYBrowseDirectoryViewImplementation.m
//  SXDrive
//
//  Created by Skylable on 17/09/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYBrowseDirectoryViewImplementation.h"

#import "SKYBrowseDirectoryViewDirectoryCell.h"
#import "SKYBrowseDirectoryViewFileCell.h"
#import "UIFont+SKYFont.h"
#import "SKYInfoKeys.h"

/**
 * Height of cells displayed in table.
 */
static CGFloat const SKYBrowseDirectoryViewTableRowsHeight = 51.f;

/**
 * Separator left inset.
 */
static CGFloat const SKYBrowseDirectoryViewSeparatorLeftInset = 45.f;

@interface SKYBrowseDirectoryViewImplementation () <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>

/**
 * Spinner when directory is loaded for the first time.
 */
@property (nonatomic, strong) UIActivityIndicatorView *loadingSpinner;

/**
 * Info label (no files, no internet).
 */
@property (nonatomic, strong) UILabel *infoLabel;

/**
 * Helper method to configure cells.
 * @param cell      Cell to configure.
 * @param indexPath Index path of the cell.
 */
- (void)configureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath;

/**
 * Curtain received from displayCurtain method is assigned here to be removed when removeCurtain is called.
 */
@property (nonatomic, weak) UIView *curtain;

@end

@implementation SKYBrowseDirectoryViewImplementation

@synthesize interactionDelegate = _interactionDelegate;
@synthesize browseDirectoryDataSource = _browseDirectoryDataSource;

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
	self = [super initWithFrame:frame style:style];
	
	if (self) {
		self.allowsMultipleSelectionDuringEditing = YES;
		self.rowHeight = SKYBrowseDirectoryViewTableRowsHeight;
		self.delegate = self;
		self.dataSource = self;
		self.separatorInset = UIEdgeInsetsMake(0, SKYBrowseDirectoryViewSeparatorLeftInset, 0, 0);
		[self registerClass:[SKYBrowseDirectoryViewDirectoryCell class]
	 forCellReuseIdentifier:SKYBrowseDirectoryViewDirectoryCellReuseIdentifier];
		[self registerClass:[SKYBrowseDirectoryViewFileCell class]
	 forCellReuseIdentifier:SKYBrowseDirectoryViewFileCellReuseIdentifier];
		
		// hides the footer
		self.tableFooterView = [UIView new];
		
		// background view
		UIView *backgroundView = [UIView new];
		backgroundView.translatesAutoresizingMaskIntoConstraints = YES;
		
		self.loadingSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		self.loadingSpinner.translatesAutoresizingMaskIntoConstraints = NO;
		self.loadingSpinner.hidesWhenStopped = YES;
		[backgroundView addSubview:self.loadingSpinner];
		[backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:self.loadingSpinner attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:backgroundView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
		[backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:self.loadingSpinner attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:backgroundView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
		
		self.infoLabel = [UILabel new];
		self.infoLabel.translatesAutoresizingMaskIntoConstraints = NO;
		self.infoLabel.text = @"";
		self.infoLabel.font = [UIFont fontForNoFilesLabel];
		self.infoLabel.hidden = YES;
		[backgroundView addSubview:self.infoLabel];
		[backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:self.infoLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:backgroundView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
		[backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:self.infoLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:backgroundView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
		
		self.backgroundView = backgroundView;
	}
	
	return self;
}

- (void)displayLoadingSpinner
{
	[self.loadingSpinner startAnimating];
	self.infoLabel.hidden = YES;
}

- (void)displaysFiles
{
	[self.loadingSpinner stopAnimating];
	self.infoLabel.hidden = YES;
}

- (void)displayEmptyDirectoryLabel
{
	self.infoLabel.text = NSLocalizedString(@"No files", @"Text displayed on the browse directory when directory is empty.");
	self.infoLabel.hidden = NO;
	[self.loadingSpinner stopAnimating];
}

- (void)displayNoInternetLabel
{
	self.infoLabel.text = NSLocalizedString(@"No internet access", @"Text displayed on the browse directory when device has no internet access.");
	self.infoLabel.hidden = NO;
	[self.loadingSpinner stopAnimating];
}

- (void)deselectSelectedCellAnimated:(BOOL)animated
{
	NSIndexPath *selectedIndexPath = [self indexPathForSelectedRow];
	
	if (selectedIndexPath != nil) {
		[self deselectRowAtIndexPath:selectedIndexPath animated:animated];
	}
}

- (void)displayCurtain:(UIView *)curtain
{
	if (self.curtain != nil) {
		[self.curtain removeFromSuperview];
		self.curtain = nil;
	}
	self.curtain = curtain;
	
	curtain.translatesAutoresizingMaskIntoConstraints = NO;
	[self.backgroundView addSubview:curtain];

	[self.backgroundView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": curtain}]];
	[self.backgroundView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view": curtain}]];
}

- (void)removeCurtain
{
	[self.curtain removeFromSuperview];
}

- (void)displayAddNewDirectoryInterface
{
	NSString *localizedTitle = NSLocalizedString(@"Name of new directory", @"Title for new directory alert.");
	NSString *localizedCreateButton = NSLocalizedString(@"Create", @"Create button for new directory alert.");

	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:localizedTitle
													message:nil
												   delegate:self
										  cancelButtonTitle:NSLocalizedString(@"Cancel", @"Generic cancel")
										  otherButtonTitles:localizedCreateButton, nil];
	alert.alertViewStyle = UIAlertViewStylePlainTextInput;
	[alert show];
}

- (void)showSelectionView
{
	// reloads data to be sure there isn't any cell that's currently in editing state, basicly it's a bug in iOS
	[self reloadData];
	
	[self setEditing:YES animated:YES];
}

- (void)hideSelectionView
{
	[self setEditing:NO animated:YES];
}

- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self tableView:self didSelectRowAtIndexPath:indexPath];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [self.browseDirectoryDataSource numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.browseDirectoryDataSource numberOfRowsInSection:section];
}

- (void)configureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
	if ([self.browseDirectoryDataSource isRowAtIndexPathDirectory:indexPath] == YES) {
		[(SKYBrowseDirectoryViewDirectoryCell *)cell fillWithDirectoryName:[self.browseDirectoryDataSource nameOfItemAtIndexPath:indexPath]];
	}
	else {
		[(SKYBrowseDirectoryViewFileCell *)cell fillWithFileName:[self.browseDirectoryDataSource nameOfItemAtIndexPath:indexPath]
														fileSize:[self.browseDirectoryDataSource formattedSizeOfItemAtIndexPath:indexPath]
												modificationDate:[self.browseDirectoryDataSource modificationDateOfItemAtIndexPath:indexPath]
														withStar:[self.browseDirectoryDataSource isItemFavouritedAtIndexPath:indexPath]
															item:[self.browseDirectoryDataSource itemAtIndexPath:indexPath]
		];
	}
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return  [self.browseDirectoryDataSource canEditItemAtIndexPath:indexPath] ||
            [self.browseDirectoryDataSource canShareItemAtIndexPath:indexPath] ||
            [self.browseDirectoryDataSource canShowRevisionsForItemAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = nil;
	
	if ([self.browseDirectoryDataSource isRowAtIndexPathDirectory:indexPath] == YES) {
		cell = [tableView dequeueReusableCellWithIdentifier:SKYBrowseDirectoryViewDirectoryCellReuseIdentifier
											   forIndexPath:indexPath];
	}
	else {
		cell = [tableView dequeueReusableCellWithIdentifier:SKYBrowseDirectoryViewFileCellReuseIdentifier
											   forIndexPath:indexPath];
        if ([[self.interactionDelegate controllerBrowserMode] isEqualToString:SKYBrowserModeChooseDirectory]) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
	}
	
	[self configureCell:cell forIndexPath:indexPath];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.interactionDelegate userDidSelectItemAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (tableView.editing == YES) {
		[self.interactionDelegate userDidSelectItemAtIndexPath:indexPath];
	}
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *array = [NSMutableArray array];
    UITableViewRowAction *action;
    if ([self.browseDirectoryDataSource canEditItemAtIndexPath:indexPath]) {
        action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Delete"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
            [tableView setEditing:NO animated:YES];
            [self.interactionDelegate userWantsToDeleteItemAtIndexPaths:@[indexPath]];
        }];
        action.backgroundColor = [UIColor colorWithRed:252.0/255.0 green:61.0/255.0 blue:57.0/255.0 alpha:1.0];
        [array addObject:action];
    }
    if ([self.browseDirectoryDataSource canShareItemAtIndexPath:indexPath]) {
        action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Share" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            [tableView setEditing:NO animated:YES];
            [self.interactionDelegate userWantsToGetPublicLinkForItemAtIndexPath:indexPath];
        }];
        action.backgroundColor = [UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:204.0/255.0 alpha:1.0];
        [array addObject:action];
    }
    if ([self.browseDirectoryDataSource canShowRevisionsForItemAtIndexPath:indexPath]) {
        action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Revisions" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            [tableView setEditing:NO animated:YES];
            [self.interactionDelegate userWantsToShowRevisionsForItemAtIndexPath:indexPath];
        }];
        action.backgroundColor = [UIColor colorWithRed:23.0/255.0 green:126.0/255.0 blue:251.0/255.0 alpha:1.0];
        [array addObject:action];
    }
    
    return [NSArray arrayWithArray:array];
}

- (void)addPendingUpdatesView:(id <SKYPendingUploadsView>)view
{
	[view setPresentingTableView:self];
	self.tableHeaderView = (UIView *)view;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1) {
		NSString *name = [alertView textFieldAtIndex:0].text;
		
		if (name.length > 0) {
			[self.interactionDelegate userWantsToCreateDirectoryWithName:name];
		}
	}
}

@end

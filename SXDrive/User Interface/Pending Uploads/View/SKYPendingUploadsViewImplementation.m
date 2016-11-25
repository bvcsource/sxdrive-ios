//
//  SKYPendingUploadsViewImplementation.m
//  SXDrive
//
//  Created by Skylable on 16/11/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYPendingUploadsViewImplementation.h"

#import "SKYPendingUploadsViewCell.h"
#import "UIColor+SKYColor.h"
#import "SKYInfoKeys.h"
#import "UIFont+SKYFont.h"

/**
 * Height of cells displayed in table.
 */
static CGFloat const SKYPendingUploadsViewTableRowsHeight = 51.f;

/**
 * Separator left inset.
 */
static CGFloat const SKYPendingUploadsViewSeparatorLeftInset = 45.f;

@interface SKYPendingUploadsViewImplementation () <UITableViewDelegate, UITableViewDataSource>

/**
 * Info label (no active uploads).
 */
@property (nonatomic, strong) UILabel *infoLabel;

/**
 * Displays footer (solid line).
 */
- (void)addFooter;

/**
 * Displays no active uploads label.
 */
- (void)displayNoActiveUploadsLabel;

/**
 * Hides no active uploads label.
 */
- (void)displayUploads;

@end

@implementation SKYPendingUploadsViewImplementation

@synthesize interactionDelegate = _interactionDelegate;
@synthesize pendingUploadsDataSource = _pendingUploadsDataSource;
@synthesize presentingTableView = _presentingTableView;

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
	self = [super initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 44 * 3) style:style];
	
	if (self) {
		self.delegate = self;
		self.dataSource = self;
		self.separatorInset = UIEdgeInsetsMake(0, SKYPendingUploadsViewSeparatorLeftInset, 0, 0);
		
		self.rowHeight = SKYPendingUploadsViewTableRowsHeight;
        [self registerClass:[SKYPendingUploadsViewCell class] forCellReuseIdentifier:SKYPendingUploadsViewBuiltInCellReuseIdentifier];
        [self registerClass:[SKYPendingUploadsViewCell class] forCellReuseIdentifier:SKYPendingUploadsViewSummaryCellReuseIdentifier];
        
        // hides the footer
        self.tableFooterView = [UIView new];
        
        // background view
        UIView *backgroundView = [UIView new];
        backgroundView.translatesAutoresizingMaskIntoConstraints = YES;
        
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

- (void)addFooter
{
	UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
	footer.backgroundColor = self.separatorColor;
	self.tableFooterView = footer;
}

- (void)displayNoActiveUploadsLabel {
    self.infoLabel.text = NSLocalizedString(@"No active uploads", @"Text displayed on the uploads summary when there is no activa uploads.");
    self.infoLabel.hidden = NO;
}

- (void)displayUploads {
    self.infoLabel.hidden = YES;
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.pendingUploadsDataSource numberOfItemSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.pendingUploadsDataSource numberOfItemsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SKYPendingUploadsViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self.interactionDelegate.controllerUploadsMode isEqualToString:SKYUploadsModeBuiltIn] ? SKYPendingUploadsViewBuiltInCellReuseIdentifier:SKYPendingUploadsViewSummaryCellReuseIdentifier forIndexPath:indexPath];
	
	cell.indexPath = indexPath;
	cell.interactionDelegate = self.interactionDelegate;
	
    BOOL uploadCompleted = [self.pendingUploadsDataSource uploadCompletedForItemAtIndexPath:indexPath];
    NSString *detailsTest = uploadCompleted ? [NSString stringWithFormat:@"%@   %@", [self.pendingUploadsDataSource formattedSizeOfItemAtIndexPath:indexPath], [self.pendingUploadsDataSource modificationDateOfItemAtIndexPath:indexPath]]:[self.pendingUploadsDataSource pathForItemAtIndexPath:indexPath];
	[cell fillWithName:[self.pendingUploadsDataSource nameOfItemAtIndexPath:indexPath]
           detailsText:detailsTest
              progress:uploadCompleted ? 1.0:[self.pendingUploadsDataSource progressForItemAtIndexPath:indexPath]
			 iconImage:[self.pendingUploadsDataSource iconForItemAtIndexPath:indexPath]
                  path:[self.pendingUploadsDataSource pathForItemAtIndexPath:indexPath]
	 ];
    cell.backgroundColor = uploadCompleted ? [UIColor whiteColor]:[UIColor skyColorForPendingUploadCellBackground];
    cell.selectionStyle = uploadCompleted ? UITableViewCellSelectionStyleDefault:UITableViewCellSelectionStyleNone;
	
	return cell;
}

- (void)reloadData
{
	[super reloadData];
	
    if ([self.interactionDelegate.controllerUploadsMode isEqualToString:SKYUploadsModeBuiltIn]) {
        if ([self numberOfRowsInSection:0] > 0) {
            [self addFooter];
        }
        else {
            self.tableFooterView = nil;
        }
        
        self.presentingTableView.tableHeaderView = nil;
        self.frame = CGRectMake(0, 0, self.contentSize.width, self.contentSize.height);
        self.presentingTableView.tableHeaderView = self;
    } else if ([self.interactionDelegate.controllerUploadsMode isEqualToString:SKYUploadsModeSummary]) {
        if ([self numberOfRowsInSection:0] == 0) {
            [self displayNoActiveUploadsLabel];
        } else {
            [self displayUploads];
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.pendingUploadsDataSource itemSectionTitle:section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL uploadCompleted = [self.pendingUploadsDataSource uploadCompletedForItemAtIndexPath:indexPath];
    if (uploadCompleted) {
        [self.interactionDelegate userDidSelectItemAtIndexPath:indexPath];
    }
}

@end

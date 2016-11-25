//
//  SKYOverlay.m
//  SXDrive
//
//  Created by Skylable on 11/11/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYOverlay.h"

@interface SKYOverlay ()

/**
 * Table view with overlay options.
 */
@property (nonatomic, strong) UITableView *tableView;

/**
 * Top constraint.
 */
@property (nonatomic, strong) NSLayoutConstraint *topConstraint;

@end

@implementation SKYOverlay

- (instancetype)init
{
	self = [super init];
	
	if (self) {
		self.userInteractionEnabled = YES;
		[self createSubviews];
	}
	
	return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self dismissOverlay];
}

- (void)dismissOverlay
{
	[UIView animateWithDuration:0.3 delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
		self.alpha = 0.f;
	} completion:^(BOOL finished) {
		[self removeFromSuperview];
	}];
}

- (void)animateEntry
{
	self.alpha = 0.f;
	
	[UIView animateWithDuration:0.3 delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
		self.alpha = 1.f;
	} completion:^(BOOL finished) {
	}];
}

- (void)createSubviews
{
	self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
	
	self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
	self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.tableFooterView = [UIView new];
	self.tableView.backgroundColor = [UIColor clearColor];
	self.tableView.bounces = NO;
	self.tableView.scrollEnabled = NO;
	self.tableView.showsVerticalScrollIndicator = NO;
	[self addSubview:self.tableView];
	
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[table]|" options:0 metrics:nil views:@{@"table": self.tableView}]];
	[self.tableView reloadData];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:self.tableView.contentSize.height]];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	if (self.topConstraint != nil) {
		[self removeConstraint:self.topConstraint];
	}
	
	self.topConstraint = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:self.navigationBar.frame.origin.y + self.navigationBar.bounds.size.height];
	
	[self addConstraint:self.topConstraint];
}

- (void)displayArrowWithCenterAtDistanceFromRightEdge:(CGFloat)rightCenterDistance
{
	UIImageView *arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow-top"]];
	arrow.translatesAutoresizingMaskIntoConstraints = NO;
	[self addSubview:arrow];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:arrow attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.tableView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:arrow attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:-rightCenterDistance]];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return nil;
}

@end

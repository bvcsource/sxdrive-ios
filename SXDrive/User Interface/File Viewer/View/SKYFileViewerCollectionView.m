//
//  SKYFileViewerCollectionView.m
//  SXDrive
//
//  Created by Skylable on 21/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYFileViewerCollectionView.h"

#import "NSArray+Extras.h"

/**
 * String representation of `currentPage` property.
 */
NSString * const SKYFileViewerCollectionViewCurrentPagePropertyName = @"currentPage";

@interface SKYFileViewerCollectionView ()

/**
 * Property redeclaration to have write access.
 */
@property (nonatomic) NSUInteger currentPage;

/**
 * Helper method to calculate the currentPage property.
 */
- (void)calculateCurrentPage;

@end

@implementation SKYFileViewerCollectionView

- (void)calculateCurrentPage
{
	NSUInteger currentPage = 0;
	
	NSArray *visibleIndexPaths = [[self indexPathsForVisibleItems] sortedArrayUsingSelector:@selector(compare:)];
	NSArray *centeredIndexPaths = [visibleIndexPaths middleObjects];
	
	if (centeredIndexPaths.count != 0) {
		if (centeredIndexPaths.count == 1) {
			NSIndexPath *indexPath = centeredIndexPaths[0];
			
			currentPage = indexPath.row;
		}
		else {
			UICollectionViewCell *rightCell = [self cellForItemAtIndexPath:centeredIndexPaths[1]];
			
			CGFloat minimumInteritemSpacing = [(UICollectionViewFlowLayout *)self.collectionViewLayout minimumInteritemSpacing];
			if (rightCell.frame.origin.x - self.bounds.size.width / 2.0 - minimumInteritemSpacing / 2.0 < self.contentOffset.x) {
				currentPage = [centeredIndexPaths[1] row];
			}
			else {
				currentPage = [centeredIndexPaths[0] row];
			}
		}
	}
	else {
		currentPage = 0;
	}
	
	if (self.currentPage != currentPage) {
		self.currentPage = currentPage;
	}
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	[self calculateCurrentPage];
}

- (void)setContentOffset:(CGPoint)contentOffset
{
	[super setContentOffset:contentOffset];
	
	[self calculateCurrentPage];
}

@end

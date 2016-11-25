//
//  SKYFileViewerCollectionViewLayout.m
//  SXDrive
//
//  Created by Skylable on 15/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYFileViewerCollectionViewLayout.h"

@interface SKYFileViewerCollectionViewLayout ()

/**
 * Helper property.
 */
@property (nonatomic, assign) CGFloat previousOffset;

@end

@implementation SKYFileViewerCollectionViewLayout

// By Dmitry Zhukov (http://stackoverflow.com/questions/23990863/uicollectionview-cell-scroll-to-centre) + Skylable
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
	NSInteger itemsCount = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:0];
	
	if ((self.previousOffset > self.collectionView.contentOffset.x) && (velocity.x < 0.0f)) {
		self.currentPage = MAX(self.currentPage - 1, 0);
	}
	else if ((self.previousOffset < self.collectionView.contentOffset.x) && (velocity.x > 0.0f)) {
		self.currentPage = MIN(self.currentPage + 1, itemsCount - 1);
	}
	
	// Update offset by using item size + spacing
	id <UICollectionViewDelegateFlowLayout> flowDelegate = (id <UICollectionViewDelegateFlowLayout>)self.collectionView.delegate;
	CGFloat updatedOffset = ([flowDelegate collectionView:self.collectionView layout:nil sizeForItemAtIndexPath:nil].width + self.minimumInteritemSpacing) * self.currentPage;
	self.previousOffset = updatedOffset;
	
	return CGPointMake(updatedOffset, proposedContentOffset.y);
}

@end

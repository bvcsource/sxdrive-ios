
@import Foundation;

@class SKYItem;

@protocol SKYBigTransfersManager <NSObject>

- (void)manageDownloadForFile:(SKYItem *)item completion:(void (^)(BOOL download))completion;

- (void)manageUploadForFileWithSize:(unsigned long long)size completion:(void (^)(BOOL upload))completion;

- (BOOL)canDownloadFavouriteFile:(SKYItem *)item;

@end

//
//  SKYBackgrounMediaUploadManager.m
//  SXDrive
//
//  Created by Skylable on 7/20/15.
//  Copyright (c) 2015 Skylable. All rights reserved.
//

#import "SKYBackgrounMediaUploadManager.h"
#import "SKYConfig.h"
#import <Photos/Photos.h>
#import "SKYAppInjector.h"
#import "SKYItem.h"
#import "SKYItem+Extras.h"
#import "SKYNotificationNames.h"
#import "NSDateFormatter+Extras.h"
#import "SKYInfoKeys.h"
#import <AFNetworking/AFNetworkReachabilityManager.h>

@interface SKYBackgrounMediaUploadManager ()

@property (nonatomic, strong) id <SKYPersistence> _persistence;

@property (nonatomic, strong) void (^_completionHandler)();
@property (nonatomic, strong) NSDate *_creationDate;
@property (nonatomic, strong) NSString *_fileName;

@property (nonatomic, assign) BOOL _inProgress;

- (NSDate *)_lastMediaUploadDate;
- (BOOL)_canUpload;
- (BOOL)_canUploadImage;
- (BOOL)_canUploadVideo;
- (NSString *)_mediaUploadDestinationPath;
- (PHAsset *)_assetToUpload;
- (void)_uploadAsset:(PHAsset *)asset;
- (void)_updateLastMediaUploadDate;
- (void)_uploadNextAsset;

@end

@implementation SKYBackgrounMediaUploadManager

+ (SKYBackgrounMediaUploadManager *)manager {
    static SKYBackgrounMediaUploadManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (id)init {
    self = [super init];
    if (self) {
        self._persistence = [SKYAppInjector injectObjectForProtocol:@protocol(SKYPersistence)];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadDidFinish:) name:SKYUploadDidFinishNotification object:nil];
    }
    
    return self;
}

#pragma mark - Notifications

- (void)uploadDidFinish:(NSNotification *)notification {
    SKYItem *item = (SKYItem *)notification.object;
    if ([self._fileName isEqualToString:item.name]) {
        if (self._inProgress) {
            [self _updateLastMediaUploadDate];
            [self _uploadNextAsset];
        } else {
            self._completionHandler();
        }
    }
    [self _updateLastMediaUploadDate];
}

#pragma mark - Auxiliary

- (void)startUploadWithCompletionHandler:(void(^)(void))handler {
    if (![self _canUpload]) {
        handler();
    } else {
        self._completionHandler = handler;
        self._inProgress = YES;
        [self _uploadNextAsset];

    }
}

- (void)cancelUpload {
    if (self._inProgress) {
        self._inProgress = NO;
        self._completionHandler();
    }
}

#pragma mark - Private

- (NSDate *)_lastMediaUploadDate {
    NSDate *date = [SKYConfig lastMediaUploadDate];
    if (!date) {
        date = [SKYConfig applicationInstallationDate];
    }
    return date;
}

- (BOOL)_canUpload {
    return [SKYConfig mediaUploadEnabled];
}

- (BOOL)_canUploadImage {
    return [AFNetworkReachabilityManager sharedManager].reachableViaWiFi || [SKYConfig photoUploadOnCellularEnabled];
}

- (BOOL)_canUploadVideo {
    return [AFNetworkReachabilityManager sharedManager].reachableViaWiFi || [SKYConfig videoUploadOnCellularEnabled];
}

- (NSString *)_mediaUploadDestinationPath {
    return [SKYConfig mediaUploadDestinationPath];
}

- (PHAsset *)_assetToUpload {
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    fetchOptions.predicate = [NSPredicate predicateWithFormat:@"%K > %@", @"creationDate", [self _lastMediaUploadDate]];
    PHFetchResult *collection = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    if(!collection || !collection.count)
        return nil;
    PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection[0] options:fetchOptions];
    
    return fetchResult > 0 ? [fetchResult firstObject]:nil;
}

- (void)_uploadAsset:(PHAsset *)asset {
    PHImageManager *manager = [PHImageManager defaultManager];
    self._creationDate = asset.creationDate;
    NSString *dateString = [[NSDateFormatter dateFormatterForMediaNames] stringFromDate:self._creationDate];
    
    if (asset.mediaType == PHAssetMediaTypeImage) {
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.synchronous = YES;
        options.version = PHImageRequestOptionsVersionCurrent;
        [manager requestImageDataForAsset:asset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
            if ([imageData length] > 0 && [self _canUploadImage]) {
                NSString *extension = [dataUTI pathExtension];
                self._fileName = [SKYConstantPhotoFilename stringByAppendingFormat:@"_%@.%@", dateString, extension];
                NSLog(@"uploading photo in background: %@", self._fileName);
                [self._persistence addFileAtPath:[NSString stringWithFormat:@"%@/%@", [self _mediaUploadDestinationPath], self._fileName] content:imageData];
            } else {
                self._completionHandler();
            }
        }];
    }
    
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.version =  PHVideoRequestOptionsVersionCurrent;
        options.deliveryMode = PHVideoRequestOptionsDeliveryModeFastFormat;
        [manager requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset *videoAsset, AVAudioMix *audioMix, NSDictionary *info){
            dispatch_async(dispatch_get_main_queue(), ^{
                NSData *videoData = [NSData dataWithContentsOfURL: ((AVURLAsset *)videoAsset).URL];
                if ([videoData length] > 0 && [self _canUploadVideo]) {
                    self._fileName = [SKYConstantMovieFilename stringByAppendingFormat:@"_%@.MOV", dateString];
                    NSLog(@"uploading video in background: %@", self._fileName);
                    [self._persistence addFileAtPath:[NSString stringWithFormat:@"%@/%@", [self _mediaUploadDestinationPath], self._fileName] content:videoData];
                } else {
                    self._completionHandler();
                }
            });
        }];
    }
}

- (void)_updateLastMediaUploadDate {
    if (self._creationDate) {
        [SKYConfig setLastMediaUploadDate:self._creationDate];
        self._creationDate = nil;
    }
}

- (void)_uploadNextAsset {
    PHAsset *asset = [self _assetToUpload];
    if (asset) {
        [self _uploadAsset:asset];
    } else {
        [self cancelUpload];
    }
}

@end

//
//  NSFileManager+ExtrasTests.m
//  SXDrive
//
//  Created by Skylable on 20/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "NSFileManager+Extras.h"

#import <Kiwi/Kiwi.h>

/**
 * Name of the directory where files waiting to be uploaded are kept.
 */
static NSString * SKYPendingUploadDirectoryName = @"SKYPendingUploadDirectory";

/**
 * Name of the directory where downloaded files are stored (not favourite).
 */
static NSString * SKYOrdinaryFilesDirectoryName = @"SKYOrdinaryFilesDirectory";

/**
 * Name of the directory where favourite files are stored.
 */
static NSString * SKYFavouriteFilesDirectoryName = @"SKYFavouriteFilesDirectory";

/**
 * Name of the directory where temporary files are stored.
 */
static NSString * SKYTemporaryFilesDirectoryName = @"SKYTemporaryFilesDirectory";

SPEC_BEGIN(NSFileManage_ExtrasTests)

describe(@"NSFileManage_ExtrasTests", ^{
	
	__block id mockFileManager;
	
	beforeEach(^{
		mockFileManager = [KWMock mockForClass:[NSFileManager class]];
		[NSFileManager stub:@selector(defaultManager) andReturn:mockFileManager];
	});
	
	context(@"sizeOfFileAtPath:", ^{
		it(@"should return the size from file manager", ^{
			id mockPath = [KWMock mockForClass:[NSString class]];
			id mockAttributes = [KWMock mockForClass:[NSDictionary class]];
			id mockFileSizeNumber = [KWMock mockForClass:[NSNumber class]];
			
			unsigned long long expectedSize = 412335;
			
			[[mockFileManager should] receive:@selector(attributesOfItemAtPath:error:) andReturn:mockAttributes withArguments:mockPath, any()];
			[[mockAttributes should] receive:@selector(objectForKeyedSubscript:) andReturn:mockFileSizeNumber withArguments:NSFileSize];
			[[mockFileSizeNumber should] receive:@selector(unsignedLongLongValue) andReturn:theValue(expectedSize)];
			
			[[theValue([NSFileManager sizeOfFileAtPath:mockPath]) should] equal:theValue(expectedSize)];
		});
	});
	
	context(@"pathToPendingUploadDirectory", ^{
		it(@"should call the helper method and return path", ^{
			
			id mockPath = [KWMock mockForClass:[NSString class]];
			[NSFileManager stub:@selector(libraryCachesPath) andReturn:mockPath];
			
			[[mockPath should] receive:@selector(stringByAppendingPathComponent:) andReturn:mockPath withArguments:SKYPendingUploadDirectoryName];
			
			[[mockFileManager should] receive:@selector(createDirectoryIfNeededAtPath:) withArguments:mockPath];
			
			id result = [NSFileManager pathToPendingUploadDirectory];
			[[result should] equal:mockPath];
		});
	});
	
	context(@"urlToPendingUploadDirectory", ^{
		it(@"should create file URL out of pathToPendingUploadDirectory", ^{
			id mockPath = [KWMock mockForClass:[NSString class]];
			[NSFileManager stub:@selector(pathToPendingUploadDirectory) andReturn:mockPath];
			
			id mockURL = [KWMock mockForClass:[NSURL class]];
			[NSURL stub:@selector(fileURLWithPath:) andReturn:mockURL withArguments:mockPath];
			
			[[[NSFileManager urlToPendingUploadDirectory] should] equal:mockURL];
		});
	});
	
	context(@"pathForOrdinaryFiles", ^{
		it(@"should call the helper method and return path", ^{
			
			id mockPath = [KWMock mockForClass:[NSString class]];
			[NSFileManager stub:@selector(libraryCachesPath) andReturn:mockPath];
			
			[[mockPath should] receive:@selector(stringByAppendingPathComponent:) andReturn:mockPath withArguments:SKYOrdinaryFilesDirectoryName];
			
			[[mockFileManager should] receive:@selector(createDirectoryIfNeededAtPath:) withArguments:mockPath];
			
			id result = [NSFileManager pathToOrdinaryFiles];
			[[result should] equal:mockPath];
		});
	});
	
	context(@"pathToFavouriteFiles", ^{
		it(@"should call the helper method and return path", ^{
			
			id mockPath = [KWMock mockForClass:[NSString class]];
			[NSFileManager stub:@selector(libraryCachesPath) andReturn:mockPath];
			
			[[mockPath should] receive:@selector(stringByAppendingPathComponent:) andReturn:mockPath withArguments:SKYFavouriteFilesDirectoryName];
			
			[[mockFileManager should] receive:@selector(createDirectoryIfNeededAtPath:) withArguments:mockPath];
			
			id result = [NSFileManager pathToFavouriteFiles];
			[[result should] equal:mockPath];
		});
	});
	
	context(@"isFileOfImageType", ^{
		it(@"should return YES for images", ^{
			NSArray *imageExtensions = @[@"png", @"jpeg", @"jpg", @"tiff", @"tif", @"gif", @"bmp", @"bmpf", @"ico", @"cur", @"xbm"];
			
			BOOL result = YES;
			
			for (NSString *extension in imageExtensions) {
				NSString *path = [@"dummy-path/dummy-file" stringByAppendingPathExtension:extension];
				if ([NSFileManager isFileOfImageType:path] == NO) {
					result = NO;
					break;
				}
			}
			
			[[theValue(result) should] beYes];
		});
		
		it(@"should return NO for file without extension", ^{
			BOOL result = [NSFileManager isFileOfImageType:@"dummy-path/dummy-file"];
			
			[[theValue(result) should] beNo];
		});
		
		it(@"should return NO for may different types then images", ^{
			NSArray *imageExtensions = @[@"pdf", @"doc", @"c", @"h", @"m", @"mm", @"exe", @"dll", @"iso", @"dmg", @"mov"];
			
			BOOL result = NO;
			
			for (NSString *extension in imageExtensions) {
				NSString *path = [@"dummy-path/dummy-file" stringByAppendingPathExtension:extension];
				if ([NSFileManager isFileOfImageType:path] == YES) {
					result = YES;
					break;
				}
			}
			
			[[theValue(result) should] beNo];
		});
	});
	
	context(@"removeAllCachedAndTemporaryFiles", ^{
		it(@"should remove some folders", ^{
			
			NSString *mockPath1 = [KWMock mockForClass:[NSString class]];
			[NSFileManager stub:@selector(pathToOrdinaryFiles) andReturn:mockPath1];
			
			NSString *mockPath2 = [KWMock mockForClass:[NSString class]];
			[NSFileManager stub:@selector(pathToFavouriteFiles) andReturn:mockPath2];
			
			NSString *mockPath3 = [KWMock mockForClass:[NSString class]];
			[NSFileManager stub:@selector(pathToPendingUploadDirectory) andReturn:mockPath3];
			
			[[mockFileManager should] receive:@selector(removeItemAtPath:error:) withArguments:mockPath1, any()];
			[[mockFileManager should] receive:@selector(removeItemAtPath:error:) withArguments:mockPath2, any()];
			[[mockFileManager should] receive:@selector(removeItemAtPath:error:) withArguments:mockPath3, any()];
			[NSFileManager removeAllCachedAndTemporaryFiles];
		});
	});
});

SPEC_END

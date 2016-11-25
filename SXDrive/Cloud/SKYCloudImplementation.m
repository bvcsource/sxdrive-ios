//
//  SKYCloudImplementation.m
//  SXDrive
//
//  Created by Skylable on 18.09.2014.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYCloudImplementation.h"

#import "NSArray+Extras.h"
#import "NSString+Extras.h"
#import "SKYAppInjector.h"
#import "SKYCloudRequest.h"
#import "SKYCloudResponse.h"
#import "SKYInfoKeys.h"
#import "SKYNodeManager.h"
#import "SKYUser.h"
#import "SKYUserImplementation.h"

#import <SSKeychain/SSKeychain.h>


@interface SKYCloudImplementation ()

/**
 * User to use with cloud, lazy property.
 */
@property (nonatomic, strong) id <SKYUser> user;

/**
 * Property redeclaration to have write access.
 */
@property (nonatomic, strong) NSString *clusterID;

@end

@implementation SKYCloudImplementation

@synthesize operationManager = _operationManager;

- (instancetype)init
{
	self = [super init];
	
	if (self) {
		_operationManager = [AFHTTPRequestOperationManager manager];
	}
	
	return self;
}

- (id <SKYUser>)user
{
	if (_user == nil) {
		_user = [SKYAppInjector injectObjectForProtocol:@protocol(SKYUser)];
	}
	
	return _user;
}

- (void)listNodesWithCompletion:(SKYCloudResponseCompletionBlock)completion
{

	SKYCloudRequest *request = [SKYCloudRequest requestWithPath:@"?nodeList"
														 method:SKYConstantMethodGET
														   body:nil
														   user:self.user];

	[SKYCloudResponse processWithRequest:request nodes:[self.user nodes] operationManager:self.operationManager withCompletion:completion];
}

- (void)listVolumesWithCompletion:(SKYCloudResponseCompletionBlock)completion
{
	SKYCloudRequest *request = [SKYCloudRequest requestWithPath:@"?volumeList"
														 method:SKYConstantMethodGET
														   body:nil
														   user:self.user];
	
	[SKYCloudResponse processWithRequest:request nodes:[self.user nodes] operationManager:self.operationManager withCompletion:completion];
}

- (void)listVolumeNodes:(NSString *)volumeName completion:(SKYCloudResponseCompletionBlock)completion
{
	NSString *path = [volumeName stringByEscapingPath];
	path = [path stringByAppendingString:@"?o=locate"];
	SKYCloudRequest *request = [SKYCloudRequest requestWithPath:path
														 method:SKYConstantMethodGET
														   body:nil
														   user:self.user];
	
	[SKYCloudResponse processWithRequest:request nodes:[self.user nodes] operationManager:self.operationManager withCompletion:completion];
}

- (void)listVolumeAccessRights:(NSString *)volumeName completion:(SKYCloudResponseCompletionBlock)completion
{
	NSString *path = [volumeName stringByEscapingPath];
	path = [path stringByAppendingString:@"?o=acl"];
	SKYCloudRequest *request = [SKYCloudRequest requestWithPath:path
														 method:SKYConstantMethodGET
														   body:nil
														   user:self.user];
	
	[SKYCloudResponse processWithRequest:request nodes:[self.user nodes] operationManager:self.operationManager withCompletion:completion];
}

- (void)listDirectoryAtPath:(NSString *)path recursive:(BOOL)recursive completion:(SKYCloudResponseCompletionBlock)completion;
{
	path = [path stringByEscapingPath];
	NSArray *pathComponents = [path pathComponents];
	
	NSString *filter = nil;
	
	if (pathComponents.count > 3) {
		NSMutableArray *array = [NSMutableArray arrayWithArray:pathComponents];
		[array removeLastObject];
		[array removeObjectAtIndex:1];
		[array removeObjectAtIndex:0];
		filter = [[@"/" stringByAppendingString:[array componentsJoinedByString:@"/"]] stringByAppendingString:@"/"];
		
		path = [NSString stringWithFormat:@"/%@/", pathComponents[1]];
	}
	
	path = [path stringByAppendingString:@"?o=list"];
	
	if (recursive == YES) {
		path = [path stringByAppendingString:@"&recursive"];
	}
	
	if (filter != nil) {
//		path is already escaped
//		NSString *escapedFilter = [filter stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		path = [path stringByAppendingFormat:@"&filter=%@", filter];
	}

	SKYCloudRequest *request = [SKYCloudRequest requestWithPath:path
														 method:SKYConstantMethodGET
														   body:nil
														   user:self.user];
	
	NSArray *nodes = [SKYNodeManager nodesForVolume:path];
	[SKYCloudResponse processWithRequest:request nodes:nodes operationManager:self.operationManager withCompletion:completion];
}

- (void)listUsersWithCompletion:(SKYCloudResponseCompletionBlock)completion
{
	SKYCloudRequest *request = [SKYCloudRequest requestWithPath:@".users"
														 method:SKYConstantMethodGET
														   body:nil
														   user:self.user];
	
	[SKYCloudResponse processWithRequest:request nodes:[self.user nodes] operationManager:self.operationManager withCompletion:completion];
}

- (void)deleteFileWithPath:(NSString *)path completion:(SKYCloudResponseCompletionBlock)completion
{
	path = [path stringByEscapingPath];
	
	SKYCloudRequest *request = [SKYCloudRequest requestWithPath:path
														 method:SKYConstantMethodDELETE
														   body:nil
														   user:self.user];
	
	NSArray *nodes = [SKYNodeManager nodesForVolume:path];
	[SKYCloudResponse processWithRequest:request nodes:nodes operationManager:self.operationManager withCompletion:completion];
}

- (void)addFileWithPath:(NSString *)path size:(unsigned long long)bytes blockNames:(NSArray *)blockNames completion:(SKYCloudResponseCompletionBlock)completion
{
	path = [path stringByEscapingPath];
	NSMutableDictionary *jsonBodyDictionary = [NSMutableDictionary dictionary];
	[jsonBodyDictionary setObject:[NSNumber numberWithUnsignedLongLong:bytes] forKey:SKYCloudFileSize];
	[jsonBodyDictionary setObject:blockNames forKey:SKYCloudFileData];
	
	NSData *jsonBody = [NSJSONSerialization dataWithJSONObject:jsonBodyDictionary options:0 error:NULL];
	
	SKYCloudRequest *request = [SKYCloudRequest requestWithPath:path
														 method:SKYConstantMethodPUT
														   body:jsonBody
														   user:self.user];

	NSArray *nodes = [SKYNodeManager nodesForVolume:path];
	[SKYCloudResponse processWithRequest:request nodes:nodes operationManager:self.operationManager withCompletion:completion];
}

- (void)uploadBlockToNode:(NSString *)node uploadToken:(NSString *)uploadToken data:(NSData *)data completion:(SKYCloudResponseCompletionBlock)completion
{
	NSString *sizeAsString = [NSString stringWithFormat:@"%lu", (unsigned long)data.length];
	NSString *path = [[@".data" stringByAppendingPathComponent:sizeAsString] stringByAppendingPathComponent:uploadToken];
	
	SKYCloudRequest *request = [SKYCloudRequest requestWithPath:path
														 method:SKYConstantMethodPUT
														   body:data
														   user:self.user];
	
	[SKYCloudResponse processWithRequest:request nodes:@[node] operationManager:self.operationManager withCompletion:completion];
}

- (void)flushAddedFileWithUploadToken:(NSString *)uploadToken node:(NSString *)node completion:(SKYCloudResponseCompletionBlock)completion
{
	NSString *path = [@".upload" stringByAppendingPathComponent:uploadToken];
	
	SKYCloudRequest *request = [SKYCloudRequest requestWithPath:path
														 method:SKYConstantMethodPUT
														   body:nil
														   user:self.user];
	
	[SKYCloudResponse processWithRequest:request nodes:@[node] operationManager:self.operationManager withCompletion:completion];
}

- (void)pollWithRequestId:(NSString *)requestId node:(NSString *)node completion:(SKYCloudResponseCompletionBlock)completion
{
	NSString *path = [@".results" stringByAppendingPathComponent:requestId];
	
	SKYCloudRequest *request = [SKYCloudRequest requestWithPath:path
														 method:SKYConstantMethodGET
														   body:nil
														   user:self.user];

	[SKYCloudResponse processWithRequest:request nodes:@[node] operationManager:self.operationManager withCompletion:completion];
}

- (void)blockSizeForVolume:(NSString *)volume withFileSize:(unsigned long long)bytes completion:(SKYCloudResponseCompletionBlock)completion
{
	volume = [volume stringByEscapingPath];
	NSString *path = [volume stringByAppendingFormat:@"?o=locate&size=%llu&volumeMeta", bytes];
	SKYCloudRequest *request = [SKYCloudRequest requestWithPath:path
														 method:SKYConstantMethodGET
														   body:nil
														   user:self.user];

	[SKYCloudResponse processWithRequest:request nodes:[self.user nodes] operationManager:self.operationManager withCompletion:completion];
}

- (void)filterActiveForVolume:(NSString *)volume completion:(SKYCloudResponseCompletionBlock)completion {
    volume = [volume stringByEscapingPath];
    NSString *path = [volume stringByAppendingFormat:@"?o=locate&volumeMeta"];
    SKYCloudRequest *request = [SKYCloudRequest requestWithPath:path
                                                         method:SKYConstantMethodGET
                                                           body:nil
                                                           user:self.user];
    
    [SKYCloudResponse processWithRequest:request nodes:[self.user nodes] operationManager:self.operationManager withCompletion:completion];
}

- (void)fileAtPath:(NSString *)path completion:(SKYCloudResponseCompletionBlock)completion
{
	path = [path stringByEscapingPath];
	SKYCloudRequest *request = [SKYCloudRequest requestWithPath:path
														 method:SKYConstantMethodGET
														   body:nil
														   user:self.user];

	NSArray *nodes = [SKYNodeManager nodesForVolume:path];
	[SKYCloudResponse processWithRequest:request nodes:nodes operationManager:self.operationManager withCompletion:completion];
}

- (void)blockFromNode:(NSString *)node withName:(NSString *)name size:(unsigned long long)blockSize completion:(SKYCloudResponseCompletionBlock)completion
{
	NSString *path = [[@".data" stringByAppendingPathComponent:[NSString stringWithFormat:@"%llu", blockSize]] stringByAppendingPathComponent:name];
	SKYCloudRequest *request = [SKYCloudRequest requestWithPath:path
														 method:SKYConstantMethodGET
														   body:nil
														   user:self.user];

//	[SKYCloudResponse processWithRequest:request nodes:@[node] operationManager:self.operationManager withCompletion:completion];
    // FIXME: the application doesn't respect server order anyway, so for now it's better to rely on retry handling
    // in processWithRequest
    [SKYCloudResponse processWithRequest:request nodes:[self.user nodes] operationManager:self.operationManager withCompletion:completion];

}

- (void)publicLinkForFileAtPath:(NSString *)filePath expireTime:(NSTimeInterval)expireTime password:(NSString *)password isDirectory:(BOOL)isDirectory completion:(SKYCloudResponseCompletionBlock)completion {
    NSMutableDictionary *jsonBodyDictionary = [NSMutableDictionary dictionary];
    [jsonBodyDictionary setObject:self.user.token forKey:SKYCloudUserAccessKey];
    if(isDirectory)
        filePath = [NSString stringWithFormat:@"%@/", filePath];
    [jsonBodyDictionary setObject:filePath forKey:SKYCloudFilePath];

    NSString *username = [SSKeychain passwordForService:SKYUserKeychainSXDriveService
                                                account:SKYUserKeychainUsernameAccount];
    if(username) {
        NSString *emailExpr = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]+" ;
        NSPredicate *emailPred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailExpr];
        if([emailPred evaluateWithObject:username])
            [jsonBodyDictionary setObject:username forKey:SKYCloudLinkNotify];
    }

    if (expireTime > 0) {
        [jsonBodyDictionary setObject:[NSNumber numberWithDouble:expireTime] forKey:SKYCloudLinkExpireTime];
    }
    if ([password length] > 0) {
        [jsonBodyDictionary setObject:password forKey:SKYCloudLinkPassword];
    }
    NSData *jsonBody = [NSJSONSerialization dataWithJSONObject:jsonBodyDictionary options:0 error:NULL];
    SKYCloudRequest *request = [SKYCloudRequest requestWithPath:@"api/share"
                                                         method:SKYConstantMethodPOST
                                                           body:jsonBody
                                                           user:self.user];
    
    [SKYCloudResponse processWithRequest:request nodes:nil operationManager:self.operationManager withCompletion:completion];
}

- (void)getClusterMeta:(SKYCloudResponseCompletionBlock)completion
{
    SKYCloudRequest *request = [SKYCloudRequest requestWithPath:@"?clusterMeta"
                                                         method:SKYConstantMethodGET
                                                           body:nil
                                                           user:self.user];
    
    [SKYCloudResponse processWithRequest:request nodes:[self.user nodes] operationManager:self.operationManager withCompletion:completion];
}

@end

//
//  SKYCloudResponse.m
//  SXDrive
//
//  Created by Skylable on 18/10/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

#import "SKYCloudResponse.h"

#import "NSArray+Extras.h"
#import "SKYAppInjector.h"
#import "SKYCloudRequest.h"
#import "SKYInfoKeys.h"
#import "SKYNetworkManager.h"

#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/AFNetworkActivityIndicatorManager.h>

#ifdef DEBUG
/**
 * Number of request.
 */
int requestID = 1;
#endif

@interface SKYCloudResponse ()

/**
 * Gets the cluster ID from response.
 * @param response Response.
 * @return Cluster ID.
 */
+ (NSString *)clusterIDFromServerResponse:(NSHTTPURLResponse *)response;

/**
 * Network manager.
 */
@property (nonatomic, strong) id <SKYNetworkManager> networkManager;

/**
 * Request to be sent.
 */
@property (nonatomic, strong) SKYCloudRequest *request;

/**
 * Property redeclaration to have write access.
 */
@property (nonatomic, strong) NSHTTPURLResponse *plainResponse;

/**
 * Property redeclaration to have write access.
 */
@property (nonatomic, strong) NSData *data;

/**
 * Property redeclaration to have write access.
 */
@property (nonatomic, strong) id jsonResponse;

/**
 * Property redeclaration to have write access.
 */
@property (nonatomic, strong) NSError *connectionError;

/**
 * Property redeclaration to have write access.
 */
@property (nonatomic, strong) NSDictionary *cloudError;

/**
 * Property redeclaration to have write access.
 */
@property (nonatomic, strong) NSString *clusterID;

/**
 * Property redeclaration to have write access.
 */
@property (nonatomic, strong) NSString *node;

@end

@implementation SKYCloudResponse

+ (void)processWithRequest:(SKYCloudRequest *)request nodes:(NSArray *)nodes operationManager:(AFHTTPRequestOperationManager *)operationManager withCompletion:(SKYCloudResponseCompletionBlock)completion
{
	NSURLRequest *urlRequest = nil;
	
	NSString *randomNode = nil;
	if (nodes != nil) {
		randomNode = nodes.randomObject;
		urlRequest = [request urlRequestWithNode:randomNode];
	}
	else {
		urlRequest = [request urlRequest];
	}

	
#ifdef DEBUG
	int localRequestID = requestID;
	
	[SKYCloudResponse printRequestToConsole:urlRequest];
#endif
	
	operationManager.securityPolicy.allowInvalidCertificates = YES; // TODO: to be removed
	operationManager.responseSerializer = [AFHTTPResponseSerializer serializer];
	AFHTTPRequestOperation *operation = [operationManager HTTPRequestOperationWithRequest:urlRequest success:^(AFHTTPRequestOperation *operation, id responseObject) {
		
		SKYCloudResponse *response = [SKYCloudResponse new];
		response.statusCode = operation.response.statusCode;
		response.node = randomNode;
		response.plainResponse = operation.response;
		response.data = operation.responseData;
		
#ifdef DEBUG
		[SKYCloudResponse printResponse:response toConsoleWithLocalRequestID:localRequestID];
#endif
		
		NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:operation.responseData options:0 error:NULL];
		
		BOOL navigatedToNextNode = NO;
		
		if (jsonResponse != nil) {
			response.jsonResponse = jsonResponse;
			
			BOOL hasCloudError = [response.jsonResponse objectForKey:@"ErrorId"] != nil;
			if (hasCloudError) {
				response.cloudError = jsonResponse;
			}
			
			if (hasCloudError == YES && nodes.count > 1) {
				NSMutableArray *newNodes = [NSMutableArray arrayWithArray:nodes];
				[newNodes removeObject:randomNode];
				[SKYCloudResponse  processWithRequest:request nodes:newNodes operationManager:operationManager withCompletion:completion];
				navigatedToNextNode = YES;
			}
		}
		
		response.clusterID = [SKYCloudResponse clusterIDFromServerResponse:operation.response];
		[response.networkManager addRequestToRequestsSizeQuota:urlRequest];
		[response.networkManager addResponseToResponsesSizeQuota:operation.response body:operation.responseData];
		
		if (navigatedToNextNode == NO) {
			completion(response);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SKYCloudResponse *response = [SKYCloudResponse new];
		response.statusCode = operation.response.statusCode;
		response.node = randomNode;
		response.connectionError = error;
		response.plainResponse = operation.response;
		
		[response.networkManager addResponseToResponsesSizeQuota:operation.response body:operation.responseData];
		
#ifdef DEBUG
		[SKYCloudResponse printResponse:response toConsoleWithLocalRequestID:localRequestID];
#endif
		
		BOOL navigatedToNextNode = NO;
		
		if (/*error.code == kCFURLErrorBadServerResponse  && */ nodes.count > 1) {
			NSMutableArray *newNodes = [NSMutableArray arrayWithArray:nodes];
			[newNodes removeObject:randomNode];
			[SKYCloudResponse  processWithRequest:request nodes:newNodes operationManager:operationManager withCompletion:completion];
			navigatedToNextNode = YES;
        }
        
		if (navigatedToNextNode == NO) {
			completion(response);
		}
	}];
	[operationManager.operationQueue addOperation:operation];
}

- (id <SKYNetworkManager>)networkManager
{
	if (_networkManager == nil) {
		_networkManager = [SKYAppInjector injectObjectForProtocol:@protocol(SKYNetworkManager)];
	}
	
	return _networkManager;
}

- (NSDictionary *)jsonDictionary
{
	if ([self.jsonResponse isKindOfClass:[NSDictionary class]]) {
		return (NSDictionary *)self.jsonResponse;
	}
	else {
		return nil;
	}
}

- (BOOL)success
{
	return (self.connectionError == nil && self.cloudError == nil);
}

+ (NSString *)clusterIDFromServerResponse:(NSHTTPURLResponse *)response
{
	__block NSString *clusterID = nil;
	if (response.allHeaderFields != nil) {
		NSString *clusterString = response.allHeaderFields[SKYCloudSXClusterHeader];
		
		if (clusterString != nil) {
			NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"\\(([0-9a-z\\-]+)\\)"
																					options:NSRegularExpressionCaseInsensitive
																					  error:NULL];
			
			[regexp enumerateMatchesInString:clusterString options:0 range:NSMakeRange(0, clusterString.length) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
				
				NSRange range = match.range;
				
				// corecting range to exclude parenthasis
				range = NSMakeRange(range.location + 1, range.length - 2);
				clusterID = [clusterString substringWithRange:range];
			}];
		}
	}
	
	return clusterID;
}

- (id)error
{
	id errorToReturn = nil;
	
	if (self.connectionError != nil) {
		errorToReturn = self.connectionError;
	}
	else if (self.cloudError != nil) {
		errorToReturn = self.cloudError;
	}
	
	return errorToReturn;
}

#ifdef DEBUG

+ (void)printRequestToConsole:(NSURLRequest *)request
{
	BOOL enabled = NO;
	
	if (enabled == YES) {
		id bodyToLog;
		if (request.HTTPBody != nil) {
			bodyToLog = [NSJSONSerialization JSONObjectWithData:request.HTTPBody options:NSJSONReadingAllowFragments error:NULL];
		}
		if (bodyToLog == nil) {
			if (request.HTTPBody.length > 10000) {
				bodyToLog = [NSString stringWithFormat:@"%lu bytes", (unsigned long)request.HTTPBody.length];
			}
			else {
				bodyToLog = request.HTTPBody;
			}
		}
		
		NSLog(@"\n---Sending request %i---\nURL: %@ (%@)\nHeaders: %@\nBody: %@", requestID, request.URL, request.HTTPMethod, [request.allHTTPHeaderFields description], request.HTTPBody);
		requestID++;
	}
}

+ (void)printResponse:(SKYCloudResponse *)response toConsoleWithLocalRequestID:(int)localRequestID
{
	BOOL enabled = NO;
	
	if (enabled == YES) {
		id dataToLog = nil;
		if (response.data != nil) {
			dataToLog = [NSJSONSerialization JSONObjectWithData:response.data options:NSJSONReadingAllowFragments error:NULL];
		}
		
		if (dataToLog == nil) {
			if (response.data.length > 10000) {
				dataToLog = [NSString stringWithFormat:@"%lu bytes", (unsigned long)response.data.length];
			}
			else {
				dataToLog = response.data;
			}
		}
		
		NSLog(@"\n---Receiving response %i---\nStatusCode: %i\nHeaders: %@\nBody: %@", localRequestID, (int)response.plainResponse.statusCode, [response.plainResponse.allHeaderFields description], dataToLog);
	}
}

#endif

@end

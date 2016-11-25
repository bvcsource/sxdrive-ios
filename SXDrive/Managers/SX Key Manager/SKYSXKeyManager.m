//
//  SKYSXKeyManager.m
//  SXDrive
//
//  Created by Skylable on 4/17/15.
//  Copyright (c) 2015 Skylable. All rights reserved.
//

#import "SKYSXKeyManager.h"
#import "AFHTTPRequestOperationManager.h"
#include <CommonCrypto/CommonHMAC.h>
#import "crypt_blowfish.h"

/*
 Sample:
 - uuid: 95189424-f084-47d3-bea5-1e006562c603; username: mmarczenko; password: fHndk87e
 - 1st step: 6f50e2ab1976ca3744bd301b5f12d699c9da2724 (hex representation)
 - 2nd step: $2b$14$ZzBgovj0whbCtR.ZVvJUkO76.EkwBLS4Za32SlFtgjiXpNLRhxORm
 - 3rd step: fad2daef305781dac6090bd5a46c4ae19b1dfe73 (hex representation)
 - last step: m+BgjXjfPD7jKj/fHqbaCEsVNI1ornhrV6Ki5rJ9RGpzkEUBgsKfbwAA
 */

@interface SXLogInData : NSObject

@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) void (^completion)(BOOL status, NSString *key);

@end

@implementation SXLogInData

@end

@interface SKYSXKeyManager ()

- (void)_logMessage:(NSString *)message;
- (void)_generateKeyForLogInData:(SXLogInData *)data;
- (void)_keyDidGenerateForLogInData:(SXLogInData *)data;

- (NSString *)_hashHexSHA1:(NSString*)input withSalt:(NSString*)salt;
- (NSData *)_hashDataSHA1:(NSString*)input withSalt:(NSString *)salt;

- (NSString *)_bCryptPassword:(NSString *)password withSaltData:(NSData *)saltData;

- (NSString *)_finalProcessingForUnsaltedUsernameHashData:(NSData *)data1 passwordHashData:(NSData *)data2;

@end

@implementation SKYSXKeyManager

#pragma mark - Singleton

+ (SKYSXKeyManager *)manager {
    static SKYSXKeyManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

#pragma mark - Init

- (id)init {
    self = [super init];
    if (self) {
        self.logEnabled = NO;
    }
    return self;
}

#pragma mark - Main

- (void)retrieveClusterUUIDForHost:(NSString *)host success:(void (^)(NSString *uuid))success failure:(void (^)(NSString *errorMessage))failure {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES; // TODO: to be removed
    [manager HEAD:host parameters:nil success:^(AFHTTPRequestOperation *operation) {
        NSString *header = [operation.response.allHeaderFields valueForKey:@"SX-Cluster"];
        NSCharacterSet *delimiters = [NSCharacterSet characterSetWithCharactersInString:@"()"];
        NSArray *splitString = [header componentsSeparatedByCharactersInSet:delimiters];
        NSString *uuid = [splitString objectAtIndex:1];
        if ([uuid length] > 0) {
            [self _logMessage:[NSString stringWithFormat:@"Cluster UUID %@", uuid]];
            success(uuid);
        } else {
            NSString *message = @"Null Cluster UUID";
            [self _logMessage:message];
            failure(message);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *message = error.description;
        [self _logMessage:message];
        failure(message);
    }];
}

- (void)generateKeyForClusterUUID:(NSString *)uuid username:(NSString *)username password:(NSString *)password completion:(void (^)(BOOL status, NSString *key))completion {
    SXLogInData *data = [SXLogInData alloc];
    data.uuid = uuid;
    data.username = [username lowercaseString];
    data.password = password;
    data.completion = completion;
    [self performSelectorInBackground:@selector(_generateKeyForLogInData:) withObject:data];
}

#pragma mark - Private

- (void)_logMessage:(NSString *)message {
    if (self.logEnabled) {
        NSLog(@"%@: %@", NSStringFromClass([self class]), message);
    }
}

- (void)_generateKeyForLogInData:(SXLogInData *)data {
    [self _logMessage:[NSString stringWithFormat:@"SHA1 1st step %@", [self _hashHexSHA1:data.username withSalt:data.uuid]]];
    NSString *bCrypt = [self _bCryptPassword:data.password withSaltData:[self _hashDataSHA1:data.username withSalt:data.uuid]];
    [self _logMessage:[NSString stringWithFormat:@"BCrypt %@", bCrypt]];
    [self _logMessage:[NSString stringWithFormat:@"SHA1 2nd step %@", [self _hashHexSHA1:bCrypt withSalt:data.uuid]]];
    data.key = [self _finalProcessingForUnsaltedUsernameHashData:[self _hashDataSHA1:data.username withSalt:@""] passwordHashData:[self _hashDataSHA1:bCrypt withSalt:data.uuid]];
    [self _logMessage:[NSString stringWithFormat:@"Key %@", data.key]];
    [self performSelectorOnMainThread:@selector(_keyDidGenerateForLogInData:) withObject:data waitUntilDone:NO];
}

- (void)_keyDidGenerateForLogInData:(SXLogInData *)data {
    if ([data.key length] > 0) {
        data.completion(YES, data.key);
    } else {
        data.completion(NO, @"");
    }
}

#pragma mark - Private: SHA1

- (NSString *)_hashHexSHA1:(NSString*)input withSalt:(NSString*)salt {
    const char *cstr = [[NSString stringWithFormat:@"%@%@", salt, input] cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:strlen(cstr)];
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, (int)data.length, digest);
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH];
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

- (NSData *)_hashDataSHA1:(NSString*)input withSalt:(NSString *)salt {
    const char *cstr = [[NSString stringWithFormat:@"%@%@", salt, input] cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:strlen(cstr)];
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, (int)data.length, digest);
    
    return [NSData dataWithBytes:(const void *)digest length:CC_SHA1_DIGEST_LENGTH];
}

#pragma mark - Private: BCrypt

- (NSString *)_bCryptPassword:(NSString *)password withSaltData:(NSData *)saltData {
    char keybuf[61];
    char settingbuf[30];
    const char *genkey, *setting;
    const char *cPassword = [password cStringUsingEncoding:NSUTF8StringEncoding];
    setting = _crypt_gensalt_blowfish_rn("$2b$", 12, [saltData bytes], 20, settingbuf, sizeof(settingbuf));
    if (!setting)
        return @"";
    genkey = _crypt_blowfish_rn(cPassword, setting, keybuf, sizeof(keybuf));
    if (!genkey)
        return @"";
    
    return [NSString stringWithCString:keybuf encoding:NSUTF8StringEncoding];
}

#pragma mark - Private: Final processing

- (NSString *)_finalProcessingForUnsaltedUsernameHashData:(NSData *)data1 passwordHashData:(NSData *)data2 {
    // concatenate data
    NSMutableData *data = [NSMutableData dataWithData:data1];
    [data appendData:data2];
    
    // append by 2 zero bytes
    unsigned char zeroByte = 0;
    [data appendBytes:&zeroByte length:1];
    [data appendBytes:&zeroByte length:1];
    
    // encode
    NSString *base64EncodedString = [data base64EncodedStringWithOptions:0];
    
    return base64EncodedString;
}

@end

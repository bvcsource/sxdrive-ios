//
//  SKYVersionPing.m
//  SXDrive
//
//  Created by Skylable on 17/01/15.
//  Copyright (c) 2015 Skylable. All rights reserved.
//

#import "SKYVersionPing.h"

#import <UIDevice-Helpers/UIDevice-Helpers.h>

#include <arpa/inet.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <ifaddrs.h>
#include <net/if.h>
#include <netdb.h>

@implementation SKYVersionPing

+ (void)ping
{
	dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
		NSString *uuid = [[UIDevice currentDevice].identifierForVendor UUIDString];
		NSString *appVersion = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] stringByReplacingOccurrencesOfString:@"." withString:@""];
		NSString *device = [[[UIDevice currentDevice] modelVersion] stringByReplacingOccurrencesOfString:@"," withString:@"-"];
		NSString *osVersion = [[[UIDevice currentDevice] systemVersion] stringByReplacingOccurrencesOfString:@"." withString:@""];
		
		NSString *urlString = [NSString stringWithFormat:@"http://%@.%@.%@.%@.ios.skylable.com", uuid, appVersion, device, osVersion];
		urlString = [urlString stringByReplacingOccurrencesOfString:@" " withString:@"_"];
		NSURL *url = [NSURL URLWithString:urlString];
		
		if (url != nil) {
			// http://stackoverflow.com/questions/5000441/how-to-perform-dns-query-on-ios
			// Ask the unix subsytem to query the DNS
			/*struct hostent *remoteHostEnt = */gethostbyname([[url host] UTF8String]);
			// Get address info from host entry
			//		struct in_addr *remoteInAddr = (struct in_addr *) remoteHostEnt->h_addr_list[0];
			// Convert numeric addr to ASCII string
			//		char *sRemoteInAddr = inet_ntoa(*remoteInAddr);
			// hostIP
			//		NSString *hostIP = [NSString stringWithUTF8String:sRemoteInAddr];
		}
	});
}

@end

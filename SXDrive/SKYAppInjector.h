//
//  SKYAppInjector.h
//  SXDrive
//
//  Created by Skylable on 18/09/14.
//  Copyright (C) 2015-2016 Skylable Ltd. <info-copyright@skylable.com>
//  License: Apache 2.0, see LICENSE for more details.
//

@import Foundation;

/**
 * Main injector used within application.
 */
@interface SKYAppInjector : NSObject

/**
 * Injects object that conforms to the given protocol.
 * @param protocol Protocol.
 * @return Injected object.
 */
+ (id)injectObjectForProtocol:(Protocol *)protocol;

/**
 * Injects object that conforms to the given protocol and pass additional info.
 * @param protocol Protocol
 * @param info     Info.
 * @return Injected object.
 */
+ (id)injectObjectForProtocol:(Protocol *)protocol info:(NSDictionary *)info;

@end

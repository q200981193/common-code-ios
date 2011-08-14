//
//  GCReachability.h
//  GUI Cocoa Common Code Library for iOS
//
//  Created by Caleb Davenport on 3/23/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#ifdef GC_SYSTEM_CONFIGURATION

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

// reachability status
enum {
    GCNotReachable,
    GCReachableViaWiFi,
    GCReachableViaWWAN
};
typedef NSUInteger GCReachabilityStatus;

// change notification name
extern NSString *GCReachabilityDidChangeNotification;

@interface GCReachability : NSObject {
@private
    SCNetworkReachabilityRef reachability;
    SCNetworkReachabilityFlags __flags;
}

// properties
@property (atomic, readonly, assign) SCNetworkReachabilityFlags flags;
@property (nonatomic, readonly, getter = isReachable) BOOL reachable;
@property (nonatomic, readonly, getter = isReachableViaWiFi) BOOL reachableViaWiFi;
@property (nonatomic, readonly, getter = isReachableViaWWAN) BOOL reachableViaWWAN;
@property (nonatomic, readonly) GCReachabilityStatus status;

// Get a reachability object
+ (GCReachability *)reachabilityForHost:(NSString *)host;

@end

#endif

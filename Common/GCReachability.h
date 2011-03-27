//
//  GCReachability.h
//  GUI Cocoa Common Code Library for iOS
//
//  Created by Caleb Davenport on 3/23/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

enum {
    GCNotReachable,
    GCReachableViaWiFi,
    GCReachableViaWWAN
};
typedef NSUInteger GCReachabilityStatus;

extern NSString * const GCReachabilityDidChangeNotification;

@interface GCReachability : NSObject {
@private
    SCNetworkReachabilityRef reachability;
}

// create
- (id)initWithHostName:(NSString *)host;

// change state
- (BOOL)startUpdatingReachability;
- (void)stopUpdatingReachability;

// check reachability
- (BOOL)isReachable;
- (BOOL)isReachableViaWiFi;
- (BOOL)isReachableViaWWAN;
- (GCReachabilityStatus)reachabilityStatus;

@end

//
//  GCReachability.h
//  GUI Cocoa Common Code Library for iOS
//
//  Created by Caleb Davenport on 3/23/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

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
extern NSString * const GCReachabilityDidChangeNotification;

@interface GCReachability : NSObject {
@private
    SCNetworkReachabilityRef reachability;
}

// use key value store
+ (GCReachability *)reachabilityForHost:(NSString *)host;

// check reachability
- (BOOL)isReachable;
- (BOOL)isReachableViaWiFi;
- (BOOL)isReachableViaWWAN;
- (GCReachabilityStatus)reachabilityStatus;

@end

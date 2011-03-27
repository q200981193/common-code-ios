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

- (id)initWithHostName:(NSString *)host;
- (BOOL)startUpdatingReachability;
- (void)stopUpdatingReachability;
- (BOOL)isReachable;
- (GCReachabilityStatus)reachabilityStatus;

@end

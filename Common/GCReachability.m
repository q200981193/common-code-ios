//
//  GCReachability.m
//  GUI Cocoa Common Code Library for iOS
//
//  Created by Caleb Davenport on 3/23/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import "GCReachability.h"

NSString * const GCReachabilityDidChangeNotification = @"GCReachabilityDidChange";

void GCReachabilityDidChangeCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info) {
    GCReachability *reachability = (GCReachability *)info;
    [[NSNotificationCenter defaultCenter]
     postNotificationName:GCReachabilityDidChangeNotification
     object:reachability];
}

@implementation GCReachability

- (id)initWithHostName:(NSString *)host {
    self = [super init];
    if (self) {
        reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, [host UTF8String]);
    }
    return self;
}
- (void)dealloc {
    [self stopUpdatingReachability];
    if (reachability != NULL) {
        CFRelease(reachability);
    }
    reachability = NULL;
    [super dealloc];
}
- (BOOL)startUpdatingReachability {
    BOOL retVal = NO;
    SCNetworkReachabilityContext context = {0, self, NULL, NULL, NULL};
    if (SCNetworkReachabilitySetCallback(reachability, GCReachabilityDidChangeCallback, &context)) {
        if (SCNetworkReachabilityScheduleWithRunLoop(reachability, CFRunLoopGetMain(), kCFRunLoopDefaultMode)) {
            return YES;
        }
    }
    return retVal;
}
- (void)stopUpdatingReachability {
    SCNetworkReachabilityUnscheduleFromRunLoop(reachability, CFRunLoopGetMain(), kCFRunLoopDefaultMode);
}


#pragma mark - check reachability
- (BOOL)isReachable {
    return ([self reachabilityStatus] != GCNotReachable);
}
- (BOOL)isReachableViaWiFi {
    return ([self reachabilityStatus] == GCReachableViaWiFi);
}
- (BOOL)isReachableViaWWAN {
    return ([self reachabilityStatus] == GCReachableViaWWAN);
}
- (GCReachabilityStatus)reachabilityStatus {
    SCNetworkReachabilityFlags flags;
    if (SCNetworkReachabilityGetFlags(reachability, &flags)) {
        
        // check reachable in general
        if ((flags & kSCNetworkReachabilityFlagsReachable) == 0) {
            return GCNotReachable;
        }
        
        // check WWAN
        if (flags & kSCNetworkReachabilityFlagsIsWWAN) {
            return GCReachableViaWWAN;
        }
        
        // intervention required
        if (flags & kSCNetworkReachabilityFlagsInterventionRequired) {
            return GCNotReachable;
        }
        
        // return wifi
        return GCReachableViaWiFi;
        
    }
    return NO;
}

@end

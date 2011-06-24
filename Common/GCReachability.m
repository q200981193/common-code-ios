//
//  GCReachability.m
//  GUI Cocoa Common Code Library for iOS
//
//  Created by Caleb Davenport on 3/23/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import "GCReachability.h"

#pragma mark - class resources
NSString * const GCReachabilityDidChangeNotification = @"GCReachabilityDidChange";
static NSMutableDictionary * reachabilityObjects = nil;

#pragma mark - callback
void GCReachabilityDidChangeCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info) {
    GCReachability *reachability = (GCReachability *)info;
    [[NSNotificationCenter defaultCenter]
     postNotificationName:GCReachabilityDidChangeNotification
     object:reachability];
}

#pragma mark - private methods
@interface GCReachability (private)
- (id)initWithHost:(NSString *)host;
- (BOOL)startUpdatingReachability;
- (void)stopUpdatingReachability;
@end
@implementation GCReachability (private)
- (id)initWithHost:(NSString *)host {
    self = [super init];
    if (self) {
        reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, [host UTF8String]);
        [self startUpdatingReachability];
    }
    return self;
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
@end

#pragma mark - public methods
@implementation GCReachability

+ (GCReachability *)reachabilityForHost:(NSString *)host {
    if (reachabilityObjects == nil) {
        reachabilityObjects = [[NSMutableDictionary alloc] initWithCapacity:1];
    }
    GCReachability *reachability = [reachabilityObjects objectForKey:host];
    if (reachability == nil) {
        reachability = [[GCReachability alloc] initWithHost:host];
        [reachabilityObjects setObject:reachability forKey:host];
        [reachability release];
    }
    return reachability;
}
- (void)dealloc {
    [self stopUpdatingReachability];
    if (reachability != NULL) {
        CFRelease(reachability);
    }
    reachability = NULL;
    [super dealloc];
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

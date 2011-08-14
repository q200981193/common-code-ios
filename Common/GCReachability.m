//
//  GCReachability.m
//  GUI Cocoa Common Code Library for iOS
//
//  Created by Caleb Davenport on 3/23/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#ifdef GC_SYSTEM_CONFIGURATION

#import "GCReachability.h"

#pragma mark - class resources
NSString *GCReachabilityDidChangeNotification = @"GCReachabilityDidChange";
static NSMutableDictionary *reachabilityObjects = nil;

#pragma mark - reachability callback
void GCReachabilityDidChangeCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info);

#pragma mark - private methods
@interface GCReachability (PrivateMethods)
- (id)initWithHost:(NSString *)host;
- (BOOL)startUpdatingReachability;
- (void)stopUpdatingReachability;
@end
@implementation GCReachability (PrivateMethods)
- (id)initWithHost:(NSString *)host {
    self = [super init];
    if (self) {
        reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, [host UTF8String]);
        self.flags = 0;
        [self startUpdatingReachability];
    }
    return self;
}
- (BOOL)startUpdatingReachability {
    BOOL result = NO;
    SCNetworkReachabilityContext context = {0, self, NULL, NULL, NULL};
    if (SCNetworkReachabilitySetCallback(reachability, GCReachabilityDidChangeCallback, &context)) {
        if (SCNetworkReachabilityScheduleWithRunLoop(reachability, CFRunLoopGetMain(), kCFRunLoopDefaultMode)) {
            result = YES;
        }
    }
    return result;
}
- (BOOL)stopUpdatingReachability {
    BOOL loop = SCNetworkReachabilityUnscheduleFromRunLoop(reachability, CFRunLoopGetMain(), kCFRunLoopDefaultMode);
    BOOL callback = SCNetworkReachabilitySetCallback(reachability, NULL, NULL);
    return (loop && callback);
}
@end

#pragma mark - public methods
@implementation GCReachability

@synthesize flags = __flags;

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
- (BOOL)isReachable {
    return ([self reachabilityStatus] != GCNotReachable);
}
- (BOOL)isReachableViaWiFi {
    return ([self reachabilityStatus] == GCReachableViaWiFi);
}
- (BOOL)isReachableViaWWAN {
    return ([self reachabilityStatus] == GCReachableViaWWAN);
}
- (GCReachabilityStatus)status {
    
    // get flags
    SCNetworkReachabilityFlags flags = self.flags;
    
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

@end

#pragma mark - reachability callbak
void GCReachabilityDidChangeCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info) {
    GCReachability *reachability = (GCReachability *)info;
    reachability.flags = flags;
    [[NSNotificationCenter defaultCenter]
     postNotificationName:GCReachabilityDidChangeNotification
     object:reachability];
}

#endif

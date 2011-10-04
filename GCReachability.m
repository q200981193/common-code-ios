/*
 
 Copyright (C) 2011 GUI Cocoa, LLC.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */

#import "GCReachability.h"

#pragma mark - class resources
static NSString *GCReachabilityDidChangeNotification = @"GCReachabilityDidChange";
static NSMutableDictionary *reachabilityObjects = nil;

#pragma mark - reachability callback
void GCReachabilityDidChangeCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info);

#pragma mark - inner interface
@interface GCReachability ()
@property (readwrite, assign) SCNetworkReachabilityFlags flags;
- (id)initWithHost:(NSString *)host;
- (BOOL)startUpdatingReachability;
- (BOOL)stopUpdatingReachability;
@end

#pragma mark - implementation
@implementation GCReachability

@synthesize flags = __flags;

#pragma mark - class methods
+ (void)initialize {
    if (self == [GCReachability class]) {
        reachabilityObjects = [[NSMutableDictionary alloc] initWithCapacity:1];
    }
}
+ (GCReachability *)reachabilityForHost:(NSString *)host {
    GCReachability *reachability = [reachabilityObjects objectForKey:host];
    if (reachability == nil) {
        reachability = [[GCReachability alloc] initWithHost:host];
        [reachabilityObjects setObject:reachability forKey:host];
        [reachability release];
    }
    return reachability;
}

#pragma mark - object methods
- (id)initWithHost:(NSString *)host {
    self = [super init];
    if (self) {
        reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, [host UTF8String]);
        self.flags = 0;
        __notifyCount = 0;
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
- (BOOL)isReachable {
    return (self.status != GCNotReachable);
}
- (BOOL)isReachableViaWiFi {
    return (self.status == GCReachableViaWiFi);
}
- (BOOL)isReachableViaWWAN {
    return (self.status == GCReachableViaWWAN);
}
- (GCReachabilityStatus)status {
    
    // get flags
    SCNetworkReachabilityFlags flags = self.flags;
    
    // check status
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0) {
        return GCNotReachable;
    }
    GCReachabilityStatus status = GCNotReachable;
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0) {
        status = GCReachableViaWiFi;
    }
    if (((flags & kSCNetworkReachabilityFlagsConnectionOnDemand) != 0) ||
        ((flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0)) {
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0) {
            status = GCReachableViaWiFi;
        }
    }
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0) {
		status = GCReachableViaWWAN;
	}
    return status;
    
}
- (void)addObserver:(id)observer selector:(SEL)selector {
    @synchronized(self) {
        [[NSNotificationCenter defaultCenter]
         addObserver:observer
         selector:selector
         name:GCReachabilityDidChangeNotification
         object:self];
        __notifyCount++;
        if (__notifyCount == 1) {
            [self startUpdatingReachability];
        }
    }
}
- (void)removeObserver:(id)observer {
    @synchronized(self) {
        [[NSNotificationCenter defaultCenter]
         removeObserver:observer
         name:GCReachabilityDidChangeNotification
         object:self];
        if (__notifyCount > 0) {
            __notifyCount--;
            if (__notifyCount == 0) {
                [self stopUpdatingReachability];
            }
        }
    }
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

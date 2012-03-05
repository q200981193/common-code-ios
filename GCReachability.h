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

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

// reachability status
enum {
    GCNotReachable,
    GCReachableViaWiFi,
    GCReachableViaWWAN
};
typedef NSUInteger GCReachabilityStatus;

// reachability api wrapper
@interface GCReachability : NSObject {
@private
    SCNetworkReachabilityRef reachability;
    SCNetworkReachabilityFlags __flags;
}

// properties
@property (readonly, assign) SCNetworkReachabilityFlags flags;
@property (nonatomic, readonly, getter = isReachable) BOOL reachable;
@property (nonatomic, readonly, getter = isReachableViaWiFi) BOOL reachableViaWiFi;
@property (nonatomic, readonly, getter = isReachableViaWWAN) BOOL reachableViaWWAN;
@property (nonatomic, readonly) GCReachabilityStatus status;

/*
 Get a reachability object.
 */
+ (GCReachability *)reachabilityForHost:(NSString *)host;

/*
 Register the given observer for notifications about reachability changes.
 These notifications are posted using NSNotificationCenter on the main thread.
 */
- (void)addObserver:(id)observer selector:(SEL)selector;

/*
 Remove the given observer from the notification dispatch table.
 */
- (void)removeObserver:(id)observer;

@end

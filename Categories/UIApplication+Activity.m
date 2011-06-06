//
//  UIApplication+Activity.m
//  QuickShot
//
//  Created by Caleb Davenport on 6/5/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import "UIApplication+Activity.h"

static NSUInteger gc_activityCount = 0;

@implementation UIApplication (Activity)
- (void)gc_pushActivity {
    gc_activityCount++;
    [self setNetworkActivityIndicatorVisible:YES];
}
- (void)gc_popActivity {
    if (gc_activityCount > 0) {
        if (--gc_activityCount == 0) {
            [self setNetworkActivityIndicatorVisible:NO];
        }
    }
}
@end

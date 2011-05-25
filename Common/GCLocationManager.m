//
//  GCLocationManager.m
//  QuickShot
//
//  Created by Caleb Davenport on 3/30/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import "GCLocationManager.h"

static CLLocationManager *gc_sharedManager;

@implementation GCLocationManager

+ (void)gc_setSharedManager:(CLLocationManager *)manager {
    [gc_sharedManager release];
    gc_sharedManager = manager;
    [gc_sharedManager retain];
}
+ (CLLocationManager *)gc_sharedManager {
    return gc_sharedManager;
}
+ (BOOL)gc_areLocationServicesAvailable {
    BOOL available = [CLLocationManager locationServicesEnabled];
	if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_4_2) {
		CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
		CLAuthorizationStatus unknown = kCLAuthorizationStatusNotDetermined;
		CLAuthorizationStatus authorized = kCLAuthorizationStatusAuthorized;
		return (available && (status == unknown || status == authorized));
	}
	else {
		return available;
	}
}

@end

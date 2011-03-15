//
//  CLLocationManager+GCExtensions.m
//  GUI Cocoa Common Code Library for iOS
//
//  Created by Caleb Davenport on 3/15/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#ifdef GC_CORE_LOCATION

#import "CLLocationManager+GCExtensions.h"

@implementation CLLocationManager (GCExtensions)

GC_SINGLETON_INSTANCE(CLLocationManager, gc_sharedManager);
+ (BOOL)gc_isLocationAvailable {
    BOOL enabled = [CLLocationManager locationServicesEnabled];
	if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_4_2) {
		CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
		CLAuthorizationStatus unknown = kCLAuthorizationStatusNotDetermined;
		CLAuthorizationStatus authorized = kCLAuthorizationStatusAuthorized;
		return (enabled && (status == unknown || status == authorized));
	}
	else {
		return enabled;
	}
}

@end

#endif

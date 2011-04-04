//
//  GCLocationManager.m
//  QuickShot
//
//  Created by Caleb Davenport on 3/30/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import "GCLocationManager.h"

@implementation GCLocationManager

@synthesize locationManager=_locaionManager;

GC_SINGLETON_INSTANCE(GCLocationManager, sharedManager);
- (id)init {
    self = [super init];
    if (self) {
        CLLocationManager *manager = [[CLLocationManager alloc] init];
        self.locationManager = manager;
        [manager release];
    }
    return self;
}
+ (BOOL)areLocationServicesAvailable {
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

//
//  CLLocationManager+GCExtensions.h
//  QuickShot
//
//  Created by Caleb Davenport on 3/15/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#ifdef GC_CORE_LOCATION

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface CLLocationManager (GCExtensions)

+ (CLLocationManager *)gc_sharedManager;
+ (BOOL)gc_isLocationAvailable;

@end

#endif

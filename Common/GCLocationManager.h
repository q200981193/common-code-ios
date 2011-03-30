//
//  GCLocationManager.h
//  QuickShot
//
//  Created by Caleb Davenport on 3/30/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface GCLocationManager : NSObject {
    
}

@property (nonatomic, retain) CLLocationManager *locationManager;

+ (GCLocationManager *)sharedManager;
+ (BOOL)areLocationServicesAvailable;

@end

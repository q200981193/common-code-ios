//
//  GCCommonIncludes.h
//  GUI Cocoa Common Code Library for iOS
//
//  Created by Caleb Davenport on 3/10/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import <TargetConditionals.h>

#import "GCSwitchCell.h"
#import "GCTextFieldCell.h"
#import "GCImagePickerController.h"
#import "GCManagedObject.h"
#import "CLLocationManager+GCExtensions.h"

typedef void (^GCNotificationBlock)(NSNotification *);

#ifndef NSFoundationVersionNumber_iOS_4_0
#define NSFoundationVersionNumber_iOS_4_0  751.32
#endif

#ifndef NSFoundationVersionNumber_iOS_4_0
#define NSFoundationVersionNumber_iOS_4_1  751.37
#endif

#ifndef NSFoundationVersionNumber_iOS_4_0
#define NSFoundationVersionNumber_iOS_4_2  751.49
#endif

#define GC_IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define GC_IS_ROOT_VIEW ([[self.navigationController viewControllers] objectAtIndex:0] == self)

#define GC_REVIEW_URL(id) [NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%@&pageNumber=0&sortOrdering=4&type=Purple+Software&mt=8", id]]

#define GC_LOG(fmt, args...) NSLog(@"%s %d " fmt, __PRETTY_FUNCTION__, __LINE__, ##args)
#ifdef DEBUG
    #define GC_LOG_INFO(fmt, args...) GC_LOG(fmt, ##args)
    #define GC_LOG_WARN(fmt, args...) GC_LOG(fmt, ##args)
    #define GC_LOG_ERROR(fmt, args...) GC_LOG(fmt, ##args)
#else
    #define GC_LOG_INFO(fmt, args...)
    #define GC_LOG_WARN(fmt, args...)
    #define GC_LOG_ERROR(fmt, args...) GC_LOG(fmt, ##args)
#endif

#define GC_SINGLETON_INSTANCE(class, variable)	\
static class *variable = nil;	\
+ (class *)variable {	\
@synchronized(self) {	\
if(variable == nil) {	\
variable = [[self alloc] init];	\
}	\
}	\
return variable;	\
}	\
+ (id)allocWithZone:(NSZone *)zone {	\
@synchronized(self) {	\
if(variable == nil) {	\
variable = [super allocWithZone:zone];	\
return variable;	\
}	\
}	\
return nil;	\
}	\
- (id)copyWithZone:(NSZone *)zone {return self;}	\
- (id)retain {return self;}	\
- (NSUInteger)retainCount {return NSUIntegerMax;}	\
- (void)release {}	\
- (id)autorelease {return self;}

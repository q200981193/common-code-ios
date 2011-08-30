//
//  GCCommonIncludes.h
//  GUI Cocoa Common Code Library for iOS
//
//  Created by Caleb Davenport on 3/10/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

// default orientation support
#define GC_SHOULD_ALLOW_ORIENTATION(orientation) \
    (GC_IS_IPAD) ? YES : (orientation == UIInterfaceOrientationPortrait);

// macro to determine if platform is ipad
#define GC_IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

// utility macros
#define GC_REVIEW_URL(id) [NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%@&pageNumber=0&sortOrdering=4&type=Purple+Software&mt=8", id]]

// custom logging
#define __GC_LOG(fmt, args...) NSLog(@"%s " fmt, __PRETTY_FUNCTION__, ##args)
#define GC_LOG_ERROR(fmt, args...) __GC_LOG(fmt, ##args)
#define GC_LOG_NSERROR(error) __GC_LOG(@"%@", error)
#ifdef DEBUG
    #define GC_LOG_INFO(fmt, args...) __GC_LOG(fmt, ##args)
#else
    #define GC_LOG_INFO(fmt, args...)
#endif

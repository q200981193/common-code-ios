//
//  GCImageBrowserController.m
//  GUI Cocoa Common Code Library for iOS
//
//  Created by Caleb Davenport on 3/26/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

#import "GCImageBrowserController.h"

@implementation GCImageBrowserController

@synthesize title=_title;
@synthesize browserDelegate=_browserDelegate;
@synthesize assetsLibrary=_assetsLibrary;
@synthesize view=_view;

#pragma mark - object lifecycle
- (id)initWithAssetsLibrary:(ALAssetsLibrary *)library {
    self = [super init];
    if (self) {
        if (library == nil) { _assetsLibrary = [[ALAssetsLibrary alloc] init]; }
        else { _assetsLibrary = [library retain]; }
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(libraryDidChange:)
         name:ALAssetsLibraryChangedNotification
         object:_assetsLibrary];
    }
    return self;
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:ALAssetsLibraryChangedNotification
     object:_assetsLibrary];
    [_assetsLibrary release];
    _assetsLibrary = nil;
    self.view = nil;
    [super dealloc];
}

#pragma mark - reload
- (void)reloadData {
    
}

#pragma mark - notifications
- (void)libraryDidChange:(NSNotification *)notif {
    [self reloadData];
}

@end

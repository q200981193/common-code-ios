//
//  GCImageBrowserViewController.m
//  GUI Cocoa Common Code Library for iOS
//
//  Created by Caleb Davenport on 4/14/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import "GCImageBrowserViewController.h"

@implementation GCImageBrowserViewController

@synthesize browser=_browser;

#pragma mark - object lifecycle
- (id)init {
    self = [super initWithNibName:nil bundle:nil];
    return self;
}
- (id)initWithNibName:(NSString *)nib bundle:(NSBundle *)bundle {
    self = [super initWithNibName:nib bundle:bundle];
    return self;
}
- (void)dealloc {
    self.browser = nil;
    [super dealloc];
}

#pragma mark - view lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.browser.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    self.browser.view.frame = self.view.bounds;
    [self.view addSubview:self.browser.view];
}

#pragma mark - accessors
- (void)setBrowser:(GCImageBrowserController *)browser {
    
    // duplicate check
    if (browser == _browser) {
        return;
    }
    
    // kvo
    [self willChangeValueForKey:@"browser"];
    
    // release and retain new
    [_browser release];
    _browser = browser;
    [_browser retain];
    
    // add view
    if ([self isViewLoaded]) {
        _browser.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
        _browser.view.frame = self.view.bounds;
        [self.view addSubview:_browser.view];
    }
    
    // kvo
    [self didChangeValueForKey:@"browser"];
    
}


@end

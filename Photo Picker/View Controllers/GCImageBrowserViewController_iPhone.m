//
//  GCImageBrowserViewController_iPhone.m
//  GUI Cocoa Common Code Library for iOS
//
//  Created by Caleb Davenport on 4/18/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import "GCImageBrowserViewController_iPhone.h"
#import "GCImageGridBrowserController.h"

@implementation GCImageBrowserViewController_iPhone

#pragma mark - object lifecycle
- (id)initWithBrowser:(GCImageBrowserController *)browser {
    self = [super initWithBrowser:browser];
    if (self) {
        self.wantsFullScreenLayout = YES;
        [self.browser
         addObserver:self
         forKeyPath:@"editing"
         options:0
         context:nil];
        [self.browser
         addObserver:self
         forKeyPath:@"actionButtonItem"
         options:0
         context:nil];
    }
    return self;
}
- (void)dealloc {
    [self.browser removeObserver:self forKeyPath:@"editing"];
    [self.browser removeObserver:self forKeyPath:@"actionButtonItem"];
    [super dealloc];
}

#pragma mark - kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    // super
    if ([super respondsToSelector:_cmd]) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
    // self
    NSArray *keys = [NSArray arrayWithObjects:@"editing", @"actionButtonItem", nil];
    if (object == self.browser && [keys containsObject:keyPath]) {
        if ([self.browser isKindOfClass:[GCImageGridBrowserController class]]) {
            GCImageGridBrowserController *gridBrowser = (GCImageGridBrowserController *)self.browser;
            if (gridBrowser.editing) {
                self.navigationItem.leftBarButtonItem = gridBrowser.cancelButtonItem;
                self.navigationItem.rightBarButtonItem = gridBrowser.actionButtonItem;
            }
            else {
                self.navigationItem.leftBarButtonItem = nil;
                self.navigationItem.rightBarButtonItem = nil;
            }
        }
    }
    
}

#pragma mark - view lifecycle
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:animated];
}

@end

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
- (id)initWithBrowser:(GCImageBrowserController *)browser {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        [self willChangeValueForKey:@"browser"];
        _browser = [browser retain];
        [self didChangeValueForKey:@"browser"];
        [_browser
         addObserver:self
         forKeyPath:@"title"
         options:0
         context:nil];
    }
    return self;
}
- (void)dealloc {
    [_browser removeObserver:self forKeyPath:@"title"];
    [self willChangeValueForKey:@"browser"];
    [_browser release];
    _browser = nil;
    [self didChangeValueForKey:@"browser"];
    [super dealloc];
}

#pragma mark - view lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.browser.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    self.browser.view.frame = self.view.bounds;
    [self.view addSubview:self.browser.view];
    [self.browser reloadData];
    self.title = self.browser.title;
}
- (void)viewWillAppear:(BOOL)animated {
    NSIndexPath *path = [self.browser.tableView indexPathForSelectedRow];
    [self.browser.tableView deselectRowAtIndexPath:path animated:animated];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.browser.tableView flashScrollIndicators];
}

#pragma mark - object methods
- (void)reloadData {
    [self.browser reloadData];
}

#pragma mark - kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.browser && [keyPath isEqualToString:@"title"]) {
        self.title = self.browser.title;
    }
}

@end

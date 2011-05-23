//
//  GCImageBrowserViewController.m
//  GUI Cocoa Common Code Library for iOS
//
//  Created by Caleb Davenport on 4/14/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import "GCImageBrowserViewController.h"
#import "GCImageBrowserTableController.h"

@implementation GCImageBrowserViewController

@synthesize browser=_browser;

#pragma mark - object lifecycle
- (id)initWithBrowser:(GCImageBrowserController *)browser {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _browser = [browser retain];
        self.title = self.browser.title;
        [self.browser
         addObserver:self
         forKeyPath:@"title"
         options:0
         context:nil];
    }
    return self;
}
- (void)dealloc {
    [self.browser removeObserver:self forKeyPath:@"title"];
    [_browser release];
    _browser = nil;
    [super dealloc];
}

#pragma mark - view lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.browser.view.frame = self.view.bounds;
    self.browser.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    [self.view addSubview:self.browser.view];
    [self.browser reloadData];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self.browser isKindOfClass:[GCImageBrowserTableController class]]) {
        GCImageBrowserTableController *tableController = (GCImageBrowserTableController *)self.browser;
        NSIndexPath *path = [tableController.tableView indexPathForSelectedRow];
        [tableController.tableView deselectRowAtIndexPath:path animated:animated];
    }
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([self.browser respondsToSelector:@selector(tableView)]) {
        GCImageBrowserTableController *tableController = (GCImageBrowserTableController *)self.browser;
        [tableController.tableView flashScrollIndicators];
        NSLog(@"%@", NSStringFromCGRect(tableController.tableView.frame));
    }
}

#pragma mark - kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.browser && [keyPath isEqualToString:@"title"]) {
        self.title = self.browser.title;
    }
}

@end

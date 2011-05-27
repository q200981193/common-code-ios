/*
 
 Copyright (C) 2011 GUI Cocoa, LLC.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */

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
    }
}

#pragma mark - kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.browser && [keyPath isEqualToString:@"title"]) {
        self.title = self.browser.title;
    }
}

@end

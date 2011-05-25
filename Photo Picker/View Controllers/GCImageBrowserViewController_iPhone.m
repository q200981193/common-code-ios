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

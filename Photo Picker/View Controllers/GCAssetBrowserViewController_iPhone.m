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

#import "GCAssetBrowserViewController_iPhone.h"
#import "GCAssetGridBrowser.h"

@implementation GCAssetBrowserViewController_iPhone

- (id)initWithBrowser:(GCAssetBrowser *)browser {
    self = [super initWithBrowser:browser];
    if (self) {
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
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    if (GC_IS_IPAD) { return YES; }
    else {
        return UIInterfaceOrientationIsLandscape(orientation) || orientation == UIInterfaceOrientationPortrait;
    }
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:animated];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    // super
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    
    // self
    NSArray *keys = [NSArray arrayWithObjects:@"editing", @"actionButtonItem", nil];
    if (object == self.browser && [keys containsObject:keyPath]) {
        if ([self.browser isKindOfClass:[GCAssetGridBrowser class]]) {
            GCAssetGridBrowser *gridBrowser = (GCAssetGridBrowser *)self.browser;
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

@end

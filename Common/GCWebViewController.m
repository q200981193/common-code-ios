//
//  GCWebViewController.m
//  QuickShot
//
//  Created by Caleb Davenport on 5/27/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import "GCWebViewController.h"

@implementation GCWebViewController

@synthesize webView=_webView;

- (id)initWithURL:(NSURL *)aURL {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        URL = [aURL copy];
    }
    return self;
}
- (void)dealloc {
    self.webView = nil;
    [URL release];
    URL = nil;
    [super dealloc];
}

#pragma mark - web view delegate
- (void)webViewDidStartLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] gc_pushActivity];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [[UIApplication sharedApplication] gc_popActivity];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] gc_popActivity];
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

#pragma mark - view lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    GC_LOG_INFO(@"%@", URL);
    NSURLRequest *request = [NSURLRequest requestWithURL:URL
                                             cachePolicy:NSURLCacheStorageNotAllowed
                                         timeoutInterval:10];
    [self.webView loadRequest:request];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    GC_SHOULD_ALLOW_ORIENTATION(orientation);
}

@end

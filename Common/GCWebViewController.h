//
//  GCWebViewController.h
//  QuickShot
//
//  Created by Caleb Davenport on 5/27/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GCWebViewController : UIViewController <UIWebViewDelegate> {
@private
    NSURL *URL;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;

- (id)initWithURL:(NSURL *)aURL;

@end

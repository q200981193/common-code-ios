//
//  GCImageBrowserViewController_iPhone.m
//  GUI Cocoa Common Code Library for iOS
//
//  Created by Caleb Davenport on 4/18/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import "GCImageBrowserViewController_iPhone.h"

@implementation GCImageBrowserViewController_iPhone

#pragma mark - object lifecycle
- (id)initWithBrowser:(GCImageBrowserController *)browser {
    self = [super initWithBrowser:browser];
    if (self) {
        self.wantsFullScreenLayout = YES;
    }
    return self;
}

#pragma mark - view lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    CGFloat top = self.navigationController.navigationBar.frame.size.height;
    self.browser.tableView.contentInset = UIEdgeInsetsMake(top, 0.0, 0.0, 0.0);
    self.browser.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(top, 0.0, 0.0, 0.0);
    self.browser.tableView.contentOffset = CGPointMake(0.0, top);
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:animated];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

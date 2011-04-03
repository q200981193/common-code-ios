//
//  GCImageBrowserController.m
//  GUI Cocoa Common Code Library for iOS
//
//  Created by Caleb Davenport on 3/26/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import "GCImageBrowserController.h"

@implementation GCImageBrowserController

@synthesize tableView=_tableView;
@synthesize imageView=_imageView;

#pragma mark - object lifecycle
- (id)init {
    self = [super initWithNibName:@"GCImageBrowserController" bundle:nil];
    return self;
}
- (void)dealloc {
    self.tableView = nil;
    self.imageView = nil;
    [super dealloc];
}

#pragma mark - view lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
	if (!GC_IS_IPAD) {
		CGFloat top = self.navigationController.navigationBar.frame.size.height;
		top += [[UIApplication sharedApplication] statusBarFrame].size.height;
		self.tableView.contentInset = UIEdgeInsetsMake(top, 0, 0, 0);
		self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(top, 0, 0, 0);
	}
}
- (void)viewDidUnload {
    [super viewDidUnload];
    self.tableView = nil;
    self.imageView = nil;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:path animated:animated];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView flashScrollIndicators];
}

#pragma mark - table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    return 0;
}
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

@end

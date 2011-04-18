//
//  GCImageBrowserController.m
//  GUI Cocoa Common Code Library for iOS
//
//  Created by Caleb Davenport on 3/26/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import "GCImageBrowserController.h"

@implementation GCImageBrowserController

@synthesize title=_title;
@synthesize dataSource=_dataSource;
@synthesize view=_view;
@synthesize tableView=_tableView;
@synthesize imageView=_imageView;

#pragma mark - object lifecycle
- (id)init {
    self = [super init];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"GCImageBrowserController" owner:self options:nil];
    }
    return self;
}
- (void)dealloc {
    self.view = nil;
    self.tableView = nil;
    self.imageView = nil;
    [super dealloc];
}

#pragma mark - reload
- (void)reloadData {
//    if (self.dataSource == nil) {
//        // raise exception
//    }
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

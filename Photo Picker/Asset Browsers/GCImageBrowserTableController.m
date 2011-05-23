//
//  GCImageBrowserTableController.m
//  GUI Cocoa Common Code Library for iOS
//
//  Created by Caleb Davenport on 4/30/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import "GCImageBrowserTableController.h"

@implementation GCImageBrowserTableController

@synthesize tableView=_tableView;
@synthesize imageView=_imageView;

#pragma mark - object lifecycle
- (id)initWithAssetsLibrary:(ALAssetsLibrary *)library {
    self = [super initWithAssetsLibrary:library];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"GCImageBrowserController" owner:self options:nil];
    }
    return self;
}
- (void)dealloc {
    self.tableView = nil;
    self.imageView = nil;
    [super dealloc];
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

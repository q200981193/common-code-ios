//
//  GCImageBrowserTableController.h
//  GUI Cocoa Common Code Library for iOS
//
//  Created by Caleb Davenport on 4/30/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import "GCImageBrowserController.h"

@interface GCImageBrowserTableController : GCImageBrowserController <UITableViewDelegate, UITableViewDataSource> {
    
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;

@end

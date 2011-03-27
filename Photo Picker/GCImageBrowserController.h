//
//  GCImageBrowserController.h
//  GUI Cocoa Common Code Library for iOS
//
//  Created by Caleb Davenport on 3/26/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import "GCImagePickerController.h"

@interface GCImageBrowserController : GCImagePickerController <UITableViewDelegate, UITableViewDataSource> {
    
}

// internal
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;

@end

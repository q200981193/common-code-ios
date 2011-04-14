//
//  GCImageBrowserController_iPad.h
//  GUI Cocoa Common Code Library for iOS
//
//  Created by Caleb Davenport on 3/31/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import "GCImageListBrowserController.h"
#import "GCImageGridBrowserController.h"

// ipad image browser
@interface GCImageBrowserViewController_iPad : UIViewController
<UIPopoverControllerDelegate, GCImageListBrowserDelegate> {
    
}

// data source
@property (nonatomic, assign) id<GCImageBrowserDataSource> dataSource;

// interface builder properties
@property (nonatomic, retain) IBOutlet UIView *leftView;
@property (nonatomic, retain) IBOutlet UIView *rightView;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;

// master & detail views
@property (nonatomic, retain) GCImageListBrowserController *listController;
@property (nonatomic, retain) GCImageGridBrowserController *gridController;

// popover
@property (nonatomic, retain) UIPopoverController *popover;

@end

//
//  GCImageBrowserController_iPad.h
//  GUI Cocoa Common Code Library for iOS
//
//  Created by Caleb Davenport on 3/31/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import "GCImageBrowserViewController.h"
#import "GCImageListBrowserController.h"
#import "GCImageGridBrowserController.h"

@class ALAssetsLibrary;

// ipad image browser
@interface GCImageBrowserViewController_iPad : GCImageBrowserViewController
<UIPopoverControllerDelegate, GCImageListBrowserDelegate> {
@private
    GCImageListBrowserController *listController;
    GCImageGridBrowserController *gridController;
    UIPopoverController *popoverController;
}

// data source
 @property (nonatomic, assign) id<GCImageBrowserDelegate> browserDelegate;

// interface builder properties
@property (nonatomic, retain) IBOutlet UIView *leftView;
@property (nonatomic, retain) IBOutlet UIView *rightView;

@end

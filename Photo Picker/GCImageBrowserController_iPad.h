//
//  GCImageBrowserController_iPad.h
//  QuickShot
//
//  Created by Caleb Davenport on 3/31/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import "GCImagePickerController.h"

@class GCImageListBrowserController;
@class GCImageGridBrowserController;

@interface GCImageBrowserController_iPad : GCImagePickerController <UIPopoverControllerDelegate> {
@private
    BOOL changeIsAnimated;
}

@property (nonatomic, retain) IBOutlet UIView *leftView;
@property (nonatomic, retain) IBOutlet UIView *rightView;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;

@property (nonatomic, retain) GCImageListBrowserController *listViewController;
@property (nonatomic, retain) GCImageGridBrowserController *gridViewController;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, assign) BOOL showAlbumList;

@end

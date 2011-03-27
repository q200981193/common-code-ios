//
//  GCImageSlideshowController.h
//  QuickShot
//
//  Created by Caleb Davenport on 3/26/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import "GCImagePickerController.h"

@interface GCImageSlideshowController : GCImagePickerController <UIScrollViewDelegate> {
@private
    ALAssetsLibrary *library;
    NSArray *assets;
    NSMutableArray *views;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

- (id)initWithAssets:(NSArray *)array;

- (IBAction)next;
- (IBAction)previous;
- (IBAction)action;

@end

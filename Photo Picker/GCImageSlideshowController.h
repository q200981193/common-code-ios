//
//  GCImageSlideshowController.h
//  GUI Cocoa Common Code Library for iOS
//
//  Created by Caleb Davenport on 3/26/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import "GCImagePickerController.h"

@interface GCImageSlideshowController : GCImagePickerController <UIScrollViewDelegate> {
@private
    
    // assets library
    ALAssetsLibrary *library;
    NSArray *assets;
    
    // uikit
    NSMutableSet *visiblePages;
    NSMutableSet *recycledPages;
    
    // queue
    dispatch_queue_t queue;
    
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;

- (id)initWithAssets:(NSArray *)array;

- (IBAction)next;
- (IBAction)previous;
- (IBAction)action;

@end

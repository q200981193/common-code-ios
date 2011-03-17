//
//  GCImageGridViewController.h
//  GUI Cocoa Common Code Library for iOS
//
//  Created by Caleb Davenport on 2/1/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import "GCImagePickerController.h"

@interface GCImageGridViewController : GCImagePickerController {
@private
    
    // used when loading group types
    ALAssetsGroupType groupTypes;
    ALAssetsLibrary *assetsLibrary;
    
    // used when loading from a given group
    ALAssetsGroup *assetsGroup;
	
    // used in all cases
    NSMutableSet *selectedAssets;
    NSArray *allAssets;
    NSString *baseTitle;
    UITapGestureRecognizer *tapRecognizer;
    
}

- (id)initWithAssetsGroupTypes:(ALAssetsGroupType)types title:(NSString *)title;
- (id)initWithAssetsGroup:(ALAssetsGroup *)group;

@end

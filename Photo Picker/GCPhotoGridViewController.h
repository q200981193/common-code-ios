//
//  QSPhotoBrowserController.h
//  QuickShot
//
//  Created by Caleb Davenport on 2/1/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#ifdef GC_ASSETS_LIBRARY

#import "GCImagePickerController.h"

@interface GCPhotoGridViewController : GCImagePickerController {
@private
    
    // used when loading group types
    ALAssetsLibrary *assetsLibrary;
    ALAssetsGroupType groupTypes;
    
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

#endif

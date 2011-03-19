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
    ALAssetsGroupType groupTypes;
    ALAssetsLibrary *assetsLibrary;
    NSString *assetsGroupIdentifier;
    NSMutableSet *selectedAssets;
    NSArray *allAssets;
    NSString *baseTitle;
}

- (id)initWithAssetsGroupTypes:(ALAssetsGroupType)types title:(NSString *)title groupID:(NSString *)groupID;

@end

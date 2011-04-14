//
//  GCImagePickerController.h
//  GUI Cocoa Common Code Library for iOS
//
//  Created by Caleb Davenport on 2/14/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "GCImageBrowserController.h"

#define GCImagePickerControllerLocalizedString(key) NSLocalizedStringFromTable(key, @"GCImagePickerController", @"")

/*
 provides a common interface for creating and interacting with
 an image picker controller
 */
@interface GCImagePickerController : UINavigationController <GCImageBrowserDataSource> {
@private
    ALAssetsLibrary *assetsLibrary;
}

// enable select action
@property (nonatomic, copy) ALAssetsLibraryAssetForURLResultBlock actionBlock;
@property (nonatomic, copy) NSString *actionTitle;
@property (nonatomic, assign) BOOL actionEnabled;

// media type
@property (nonatomic, copy) NSArray *mediaTypes;

// internal
@property (nonatomic, readonly) ALAssetsLibraryAccessFailureBlock failureBlock;

// make a picker
- (id)init;

// utility methods
+ (NSData *)dataForAssetRepresentation:(ALAssetRepresentation *)rep;
+ (void)writeDataForAssetRepresentation:(ALAssetRepresentation *)rep toFile:(NSString *)path atomically:(BOOL)atomically;
+ (NSString *)extensionForAssetRepresentation:(ALAssetRepresentation *)rep;
+ (NSString *)extensionForUTI:(CFStringRef)UTI;

@end

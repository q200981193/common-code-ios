//
//  QSPhotoPickerController.h
//  GUI Cocoa Common Code Library for iOS
//
//  Created by Caleb Davenport on 2/14/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

#define GCImagePickerControllerLocalizedString(key) NSLocalizedStringFromTable(key, @"GCImagePickerController", @"")

@interface GCImagePickerController : UIViewController {
        
}

// enable select action
@property (nonatomic, copy) ALAssetsLibraryAssetForURLResultBlock actionBlock;
@property (nonatomic, copy) NSString *actionTitle;
@property (nonatomic, assign) BOOL actionEnabled;

// media type
@property (nonatomic, copy) NSArray *mediaTypes;

// internal
@property (nonatomic, readonly) ALAssetsLibraryAccessFailureBlock failureBlock;

// methods to get a certain picker
+ (GCImagePickerController *)pickerWithSourceType:(UIImagePickerControllerSourceType)source;

// object methods
- (void)presentFromViewController:(UIViewController *)controller;
- (UIPopoverController *)popoverController;
- (ALAssetsFilter *)assetsFilter;

// utility methods
+ (NSData *)dataForAssetRepresentation:(ALAssetRepresentation *)rep;
+ (void)writeDataForAssetRepresentation:(ALAssetRepresentation *)rep toFile:(NSString *)path atomically:(BOOL)atomically;
+ (NSString *)extensionForAssetRepresentation:(ALAssetRepresentation *)rep;
+ (NSString *)extensionForUTI:(CFStringRef)UTI;

@end

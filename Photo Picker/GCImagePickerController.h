//
//  GCImagePickerController.h
//  GUI Cocoa Common Code Library for iOS
//
//  Created by Caleb Davenport on 2/14/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#ifdef GC_ASSETS_LIBRARY

#define GCPhotoPickerLocalizedString(key) NSLocalizedStringFromTable(key, @"GCImagePickerController", @"")

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef void (^GCImagePickerSelectedAssetsBlock)(ALAsset *asset);

@interface GCImagePickerController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, copy) GCImagePickerSelectedAssetsBlock actionBlock;
@property (nonatomic, copy) NSString *actionTitle;
@property (nonatomic, assign) BOOL actionEnabled;

// methods to get certain browsers
+ (GCImagePickerController *)savedPhotosViewer;
+ (GCImagePickerController *)allPhotosViewer;
+ (GCImagePickerController *)photoLibraryViewer;

// methods to help show views
- (void)presentFromViewController:(UIViewController *)controller;
- (UIPopoverController *)popoverController;

// utility methods
+ (NSData *)dataForAssetRepresentation:(ALAssetRepresentation *)rep;
+ (void)writeDataForAssetRepresentation:(ALAssetRepresentation *)rep toFile:(NSString *)path atomically:(BOOL)atomically;
+ (void)exportVideoAssetToFle:(NSString *)path atomically:(BOOL)atomically;
+ (NSString *)extensionForAssetRepresentation:(ALAssetRepresentation *)rep;
+ (NSString *)extensionForUTI:(NSString *)UTI;

@end

#endif

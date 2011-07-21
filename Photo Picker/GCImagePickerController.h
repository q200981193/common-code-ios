/*
 
 Copyright (C) 2011 GUI Cocoa, LLC.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

// block to be called on each selected asset
typedef void (^GCImagePickerControllerActionBlock) (NSURL *assetURL, BOOL *stop);

// view controller typedef
@protocol GCImagePickerController;
typedef UIViewController<GCImagePickerController> GCImagePickerViewController;

// common methods that top level controllers implement
@protocol GCImagePickerController <NSObject>
@required
@property (nonatomic, readonly, retain) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, copy) ALAssetsFilter *assetsFilter;
@property (nonatomic, copy) GCImagePickerControllerActionBlock actionBlock;
@property (nonatomic, copy) NSString *actionTitle;
@property (nonatomic, assign) BOOL actionEnabled;
@end

@interface GCImagePickerController : NSObject {
    
}

// get a picker view controller
+ (GCImagePickerViewController *)picker;

// get a localized string from the library
+ (NSString *)localizedString:(NSString *)key;

// called when assets fail to load
+ (void)failedToLoadAssetsWithError:(NSError *)error;

@end

@interface GCImagePickerController (utilities)

// get the system extension given an asset representation
+ (NSString *)extensionForAssetRepresentation:(ALAssetRepresentation *)rep;

// get the MIME type given an asset representation
+ (NSString *)MIMETypeForAssetRepresentation:(ALAssetRepresentation *)rep;

// get the system extension for a given UTI
+ (NSString *)extensionForUTI:(CFStringRef)UTI;

// get the MIME type for a given UTI
+ (NSString *)MIMETypeForUTI:(CFStringRef)UTI;

// get data given an asset representation
+ (NSData *)dataForAssetRepresentation:(ALAssetRepresentation *)rep;

// write data to a given file
+ (void)writeDataForAssetRepresentation:(ALAssetRepresentation *)rep toFile:(NSString *)path atomically:(BOOL)atomically;

@end

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

#import "GCAssetListBrowser.h"

// shortcut for loading localized resources
#define GCImagePickerControllerLocalizedString(key) \
NSLocalizedStringFromTable(key, @"GCImagePickerController", @"")

// block called for each selected asset
typedef void (^GCImagePickerControllerActionBlock)(ALAssetsLibrary *library, NSURL *URL);

// a better image picker
@interface GCImagePickerController : UINavigationController <GCAssetListBrowserDelegate> {
    
}

// multi-select action
@property (nonatomic, copy) NSString *actionTitle;
@property (nonatomic, assign) BOOL actionEnabled;
@property (nonatomic, copy) GCImagePickerControllerActionBlock actionBlock;

// media types
@property (nonatomic, copy) NSArray *mediaTypes;

// properties for internal classes
@property (nonatomic, readonly) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, readonly) ALAssetsFilter *assetsFilter;
@property (nonatomic, readonly) ALAssetsLibraryAccessFailureBlock failureBlock;

// make a picker
- (id)init;

@end

// utility methods
@interface GCImagePickerController (UtilityMethods)
+ (NSData *)dataForAssetRepresentation:(ALAssetRepresentation *)rep;
+ (void)writeDataForAssetRepresentation:(ALAssetRepresentation *)rep toFile:(NSString *)path atomically:(BOOL)atomically;
+ (NSString *)extensionForAssetRepresentation:(ALAssetRepresentation *)rep;
+ (NSString *)extensionForUTI:(CFStringRef)UTI;
@end

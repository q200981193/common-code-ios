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

#import <MobileCoreServices/MobileCoreServices.h>

#import "GCImagePickerController.h"
#import "GCIPViewController_Phone.h"
#import "GCIPViewController_Pad.h"

ALAssetsLibraryAccessFailureBlock GCImagePickerControllerLibraryFailureBlock() {
    return ^(NSError *error){
        NSLog(@"%@", error);
        NSInteger code = [error code];
        if (code == ALAssetsLibraryAccessUserDeniedError || code == ALAssetsLibraryAccessGloballyDeniedError) {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:[GCImagePickerController localizedString:@"ERROR"]
                                  message:[GCImagePickerController localizedString:@"PHOTO_ROLL_LOCATION_ERROR"]
                                  delegate:nil
                                  cancelButtonTitle:[GCImagePickerController localizedString:@"OK"]
                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:[GCImagePickerController localizedString:@"ERROR"]
                                  message:[GCImagePickerController localizedString:@"UNKNOWN_LIBRARY_ERROR"]
                                  delegate:nil
                                  cancelButtonTitle:[GCImagePickerController localizedString:@"OK"]
                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
    };
}

@implementation GCImagePickerController

+ (UIViewController<GCImagePickerController> *)picker {
    if (GC_IS_IPAD) {
        GCIPViewController_Pad *controller = [[GCIPViewController_Pad alloc] initWithNibName:nil bundle:nil];
        return [controller autorelease];
    }
    else {
        GCIPViewController_Phone *controller = [[GCIPViewController_Phone alloc] initWithRootViewController:nil];
        return [controller autorelease];
    }
}
+ (NSString *)localizedString:(NSString *)key {
    return [[NSBundle mainBundle] localizedStringForKey:key value:nil table:NSStringFromClass(self)];
}

@end

@implementation GCImagePickerController (utilities)
+ (NSString *)extensionForAssetRepresentation:(ALAssetRepresentation *)rep {
    NSString *UTI = [rep UTI];
    if (UTI == nil) {
        GC_LOG_ERROR(@"Missing UTI for asset representation %@", UTI);
        return nil;
    }
    else {
        return [GCImagePickerController extensionForUTI:(CFStringRef)UTI];
    }
}
+ (NSString *)MIMETypeForAssetRepresentation:(ALAssetRepresentation *)rep {
    NSString *UTI = [rep UTI];
    if (UTI == nil) {
        GC_LOG_ERROR(@"Missing UTI for asset representation %@", UTI);
        return nil;
    }
    else {
        return [GCImagePickerController MIMETypeForUTI:(CFStringRef)UTI];
    }
}
+ (NSString *)extensionForUTI:(CFStringRef)UTI {
    if (UTI == NULL) {
        GC_LOG_WARN(@"Requested extension for nil UTI");
        return nil;
    }
    else if (CFStringCompare(UTI, kUTTypeJPEG, 0) == kCFCompareEqualTo) {
        return @"jpg";
    }
    else {
        CFStringRef extension = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassFilenameExtension);
        if (extension == NULL) {
            GC_LOG_ERROR(@"Missing extension for UTI %@", (NSString *)UTI);
            return nil;
        }
        else {
            return [(NSString *)extension autorelease];
        }
    }
}
+ (NSString *)MIMETypeForUTI:(CFStringRef)UTI {
    if (UTI == NULL) {
        GC_LOG_WARN(@"Requested MIME for nil UTI");
        return nil;
    }
    else {
        CFStringRef MIME = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType);
        if (MIME == NULL) {
            GC_LOG_ERROR(@"Missing MIME for UTI %@", (NSString *)UTI);
            return nil;
        }
        else {
            return [(NSString *)MIME autorelease];
        }
    }
}
+ (NSData *)dataForAssetRepresentation:(ALAssetRepresentation *)rep {
    [rep retain];
    long long size = [rep size];
    long long offset = 0;
    NSMutableData *data = [NSMutableData dataWithCapacity:size];
    while (offset < size) {
        uint8_t bytes[1024];
        NSError *error = nil;
        NSUInteger written = [rep getBytes:bytes fromOffset:offset length:1024 error:&error];
        if (error != nil) {
			GC_LOG_ERROR(@"%@", error);
			data = nil;
			break;
		}
        [data appendBytes:bytes length:written];
        offset += written;
    }
    [rep release];
    return data;
}
@end

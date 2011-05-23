//
//  GCImagePickerController.m
//  GUI Cocoa Common Code Library for iOS
//
//  Created by Caleb Davenport on 2/14/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>

#import "GCImagePickerController.h"
#import "GCImageBrowserViewController_iPad.h"
#import "GCImageBrowserViewController_iPhone.h"

@implementation GCImagePickerController

#pragma mark - class methods
+ (NSData *)dataForAssetRepresentation:(ALAssetRepresentation *)rep {
    [rep retain];
    long long size = [rep size], offset = 0;
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
+ (void)writeDataForAssetRepresentation:(ALAssetRepresentation *)rep toFile:(NSString *)path atomically:(BOOL)atomically {
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return;
    }
    [rep retain];
	NSString *writePath = path;
	if (atomically) {
		writePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[path lastPathComponent]];
	}
	[[NSFileManager defaultManager] createFileAtPath:writePath contents:nil attributes:nil];
	NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:writePath];
	long long size = [rep size], offset = 0;
	while (offset < size) {
		NSMutableData *buffer = [[NSMutableData alloc] initWithLength:1024];
		NSError *error = nil;
		NSUInteger written = [rep getBytes:[buffer mutableBytes] fromOffset:offset length:1024 error:&error];
        if (error) {
			GC_LOG_ERROR(@"%@", error);
			[handle closeFile];
            [buffer release];
			[[NSFileManager defaultManager] removeItemAtPath:writePath error:nil];
            writePath = nil;
			break;
		}
        if (written == 1024) {
            [handle writeData:buffer];
        }
        else if (written > 0) {
            [handle writeData:[buffer subdataWithRange:NSMakeRange(0, written)]];
        }
        [buffer release];
		offset += written;
	}
	[handle closeFile];
	if (atomically && writePath) {
		[[NSFileManager defaultManager] moveItemAtPath:writePath toPath:path error:nil];
	}
    [rep release];
}
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

#pragma mark - properties
@synthesize selectActionTitle=_selectActionTitle;
@synthesize selectActionEnabled=_selectActionEnabled;
@synthesize mediaTypes=_mediaTypes;



@synthesize actionBlock=_actionBlock;
@synthesize failureBlock=_failureBlock;


#pragma mark - object lifecycle
- (id)init {
    self = [super init];
    if (self) {
        
        // base media types
        self.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
        
        // push root view
        if (GC_IS_IPAD) {
            GCImageBrowserViewController_iPad *controller = [[GCImageBrowserViewController_iPad alloc] init];
            controller.browserDelegate = self;
            [self pushViewController:controller animated:NO];
            [controller release];
        }
        else {
            
            // browser
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            GCImageListBrowserController *browser = [[GCImageListBrowserController alloc] initWithAssetsLibrary:library];
            browser.browserDelegate = self;
            browser.listBrowserDelegate = self;
            browser.showDisclosureIndicators = YES;
            [library release];
            
            // view
            GCImageBrowserViewController_iPhone *controller = [[GCImageBrowserViewController_iPhone alloc] initWithBrowser:browser];
            UIBarButtonItem *button = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                       target:self
                                       action:@selector(doneAction)];
            controller.navigationItem.rightBarButtonItem = button;
            [button release];
            
            // push
            [self pushViewController:controller animated:NO];
            
            // release
            [browser release];
            [controller release];
            
        }
        
//        [self willChangeValueForKey:@"failureBlock"];
//        _failureBlock = Block_copy(^(NSError *error){
//            GC_LOG_ERROR(@"%@", error);
//            if ([error code] == ALAssetsLibraryAccessUserDeniedError || [error code] == ALAssetsLibraryAccessGloballyDeniedError) {
//                UIAlertView *alert = [[UIAlertView alloc]
//                                      initWithTitle:GCImagePickerControllerLocalizedString(@"ERROR")
//                                      message:GCImagePickerControllerLocalizedString(@"PHOTO_ROLL_LOCATION_ERROR")
//                                      delegate:nil
//                                      cancelButtonTitle:GCImagePickerControllerLocalizedString(@"OK")
//                                      otherButtonTitles:nil];
//                [alert show];
//                [alert release];
//            }
//            else {
//                UIAlertView *alert = [[UIAlertView alloc]
//                                      initWithTitle:GCImagePickerControllerLocalizedString(@"ERROR")
//                                      message:GCImagePickerControllerLocalizedString(@"UNKNOWN_LIBRARY_ERROR")
//                                      delegate:nil
//                                      cancelButtonTitle:GCImagePickerControllerLocalizedString(@"OK")
//                                      otherButtonTitles:nil];
//                [alert show];
//                [alert release];
//            }
//        });
//        [self didChangeValueForKey:@"failureBlock"];
    }
    return self;
}
- (void)dealloc {
    self.mediaTypes = nil;
    self.selectActionTitle = nil;
    
//    [self willChangeValueForKey:@"failureBlock"];
//    Block_release(_failureBlock);_failureBlock = nil;
//    [self didChangeValueForKey:@"failureBlock"];
//    self.actionBlock = nil;
    [super dealloc];
}

#pragma mark - object methods
- (void)doneAction {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - data source
- (ALAssetsFilter *)assetsFilter {
    BOOL images = [self.mediaTypes containsObject:(NSString *)kUTTypeImage];
    BOOL videos = [self.mediaTypes containsObject:(NSString *)kUTTypeVideo];
    if (images && videos) { return [ALAssetsFilter allAssets]; }
    else if (videos) { return [ALAssetsFilter allVideos]; }
    else { return [ALAssetsFilter allPhotos]; }
}

#pragma mark - list browser delegate
- (void)listBrowser:(GCImageListBrowserController *)listBrowser didSelectAssetGroup:(ALAssetsGroup *)group {
    
    // get broup
    NSString *groupID = [group valueForProperty:ALAssetsGroupPropertyPersistentID];
    
    // make new browser
    GCImageGridBrowserController *browser = [[GCImageGridBrowserController alloc]
                                             initWithAssetsLibrary:listBrowser.assetsLibrary
                                             groupIdentifier:groupID];
    browser.browserDelegate = self;
    browser.assetViewPadding = 4.0;
    browser.numberOfAssetsPerRow = 4;
    
    // view controller
    GCImageBrowserViewController_iPhone *controller = [[GCImageBrowserViewController_iPhone alloc]
                                                       initWithBrowser:browser];
    
    // push
    [self pushViewController:controller animated:YES];
    
    // release
    [controller release];
    [browser release];
    
}

@end

//
//  QSPhotoPickerController.m
//  QuickShot
//
//  Created by Caleb Davenport on 2/14/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#ifdef GC_ASSETS_LIBRARY

#import <MobileCoreServices/MobileCoreServices.h>
#import <CoreLocation/CoreLocation.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "GCImagePickerController.h"

#import "GCAssetsGroupListViewController.h"
#import "GCPhotoGridViewController.h"

#import "QSDeviceManager.h"

@implementation GCImagePickerController

@synthesize tableView=_tableView;
@synthesize imageView=_imageView;
@synthesize actionBlock=_actionBlock;
@synthesize actionTitle=_actionTitle;
@synthesize actionEnabled=_actionEnabled;

#pragma mark - class methods
+ (GCImagePickerController *)savedPhotosViewer {
    GCImagePickerController *picker = [[GCPhotoGridViewController alloc]
                                       initWithAssetsGroupTypes:ALAssetsGroupSavedPhotos
                                       title:GCPhotoPickerLocalizedString(@"CAMERA_ROLL")];
	return [picker autorelease];
}
+ (GCImagePickerController *)allPhotosViewer {
    GCImagePickerController *picker = [[GCPhotoGridViewController alloc]
                                       initWithAssetsGroupTypes:ALAssetsGroupLibrary
                                       title:GCPhotoPickerLocalizedString(@"PHOTO_LIBRARY")];
	return [picker autorelease];
}
+ (GCImagePickerController *)photoLibraryViewer {
    return [[[GCAssetsGroupListViewController alloc] init] autorelease];
}
+ (NSData *)dataForAssetRepresentation:(ALAssetRepresentation *)rep {
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
    return data;
}
+ (void)writeDataForAssetRepresentation:(ALAssetRepresentation *)rep toFile:(NSString *)path atomically:(BOOL)atomically {
	NSString *writePath = path;
	if (atomically) {
		writePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[path lastPathComponent]];
	}
	[[NSFileManager defaultManager] createFileAtPath:writePath contents:nil attributes:nil];
	NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:writePath];
	long long size = [rep size], offset = 0;
	while (offset < size) {
		NSMutableData *buffer = [NSMutableData dataWithLength:1024];
		NSError *error = nil;
		NSUInteger written = [rep getBytes:[buffer mutableBytes] fromOffset:offset length:1024 error:&error];
        if (error != nil) {
			GC_LOG_ERROR(@"%@", error);
			[handle closeFile];
			[[NSFileManager defaultManager] removeItemAtPath:path error:nil];
			return;
		}
		[handle writeData:[buffer subdataWithRange:NSMakeRange(0, written)]];
		offset += written;
	}
	[handle closeFile];
	if (atomically) {
		[[NSFileManager defaultManager] moveItemAtPath:writePath toPath:path error:nil];
	}
}
+ (void)exportVideoAssetToFle:(NSString *)path atomically:(BOOL)atomically {
	
}
+ (NSString *)extensionForAssetRepresentation:(ALAssetRepresentation *)rep {
    NSString *UTI = [rep UTI];
    if (UTI == nil) {
        GC_LOG_ERROR(@"Missing UTI for asset representation %@", UTI);
        return nil;
    }
    else {
        return [GCImagePickerController extensionForUTI:UTI];
    }
}
+ (NSString *)extensionForUTI:(NSString *)UTI {
    if (UTI == nil) {
        GC_LOG_WARN(@"Requested extension for nil UTI");
        return nil;
    }
    else if ([UTI isEqualToString:(NSString *)kUTTypeJPEG]) {
        return @"jpg";
    }
    else {
        CFStringRef extension = UTTypeCopyPreferredTagWithClass((CFStringRef)UTI, kUTTagClassFilenameExtension);
        if (extension == NULL) {
            GC_LOG_ERROR(@"Missing extension for UTI %@", UTI);
            return nil;
        }
        else {
            return [(NSString *)extension autorelease];
        }
    }
}

#pragma mark - object methods
- (void)presentFromViewController:(UIViewController *)controller {
    if (GC_IS_IPAD) {
		[NSException
		 raise:NSInternalInconsistencyException
		 format:@"%s should not be called on iPad", __PRETTY_FUNCTION__];
	}
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self];
	[nav.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
	[controller presentModalViewController:nav animated:YES];
	[nav release];
}
- (UIPopoverController *)popoverController {
    if (!GC_IS_IPAD) {
		[NSException
		 raise:NSInternalInconsistencyException
		 format:@"%s should not be called on iPhone", __PRETTY_FUNCTION__];
	}
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self];
    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:nav];
    [nav release];
    return [popover autorelease];
}

#pragma mark - object lifecycle
- (id)init {
    self = [super initWithNibName:@"QSPhotoPickerController" bundle:nil];
    if (self) {
        if (!GC_IS_IPAD) {
            self.wantsFullScreenLayout = YES;
        }
		else {
			self.contentSizeForViewInPopover = CGSizeMake(320, 460);
		}
    }
    return self;
}
- (void)dealloc {
    self.actionBlock = nil;
    self.actionTitle = nil;
    self.tableView = nil;
    self.imageView = nil;
    [super dealloc];
}

#pragma mark - view lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
	if (!GC_IS_IPAD) {
		CGFloat top = self.navigationController.navigationBar.frame.size.height;
		top += [[UIApplication sharedApplication] statusBarFrame].size.height;
		self.tableView.contentInset = UIEdgeInsetsMake(top, 0, 0, 0);
		self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(top, 0, 0, 0);
	}
}
- (void)viewDidUnload {
    [super viewDidUnload];
    self.tableView = nil;
    self.imageView = nil;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:path animated:animated];
    if (self.actionEnabled && (self.actionBlock == nil || self.actionTitle == nil)) {
        [NSException
         raise:NSInternalInconsistencyException
         format:@"Attempted to show a photo library browser with action enabled but the action block or title was not specified"];
    }
}
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	if (![QSDeviceManager isLocationAvailable]) {
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:NSLocalizedString(@"LOCATION_SERVICES", @"")
							  message:NSLocalizedString(@"PHOTO_ROLL_LOCATION_ERROR", @"")
							  delegate:nil
							  cancelButtonTitle:NSLocalizedString(@"OK", @"")
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

#pragma mark - table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    return 0;
}
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

@end

#endif

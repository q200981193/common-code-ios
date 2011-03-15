//
//  QSAssetsGroupListController.h
//  QuickShot
//
//  Created by Caleb Davenport on 2/3/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#ifdef GC_ASSETS_LIBRARY

#import "GCImagePickerController.h"

@interface GCImageListViewController : GCImagePickerController {
@private
	NSArray *assetsGrouops;
	ALAssetsLibrary *assetsLibrary;
}

@end

#endif

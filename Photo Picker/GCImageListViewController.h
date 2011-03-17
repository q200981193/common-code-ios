//
//  QSAssetsGroupListController.h
//  QuickShot
//
//  Created by Caleb Davenport on 2/3/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import "GCImagePickerController.h"

@interface GCImageListViewController : GCImagePickerController {
@private
    ALAssetsLibrary *assetsLibrary;
	NSArray *assetsGroups;
}

@end

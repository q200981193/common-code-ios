//
//  QSAssetsGroupListController.h
//  GUI Cocoa Common Code Library for iOS
//
//  Created by Caleb Davenport on 2/3/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import "GCImageBrowserController.h"

typedef void (^GCImageListBrowserSelectedGroupBlock) (ALAssetsGroup *group);

@interface GCImageListBrowserController : GCImageBrowserController {
@private
    ALAssetsLibrary *assetsLibrary;
	NSArray *_assetsGroups;
}

@property (nonatomic, copy) GCImageListBrowserSelectedGroupBlock selectedGroupBlock;
@property (nonatomic, readonly) NSArray *assetsGroups;

@end

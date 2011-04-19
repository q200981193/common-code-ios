//
//  GCImageListBrowserController.h
//  GUI Cocoa Common Code Library for iOS
//
//  Created by Caleb Davenport on 2/3/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import "GCImageBrowserController.h"

@class ALAssetsGroup;
@class GCImageListBrowserController;

// list browser delegate
@protocol GCImageListBrowserDelegate <NSObject>
@required
- (void)listBrowser:(GCImageListBrowserController *)controller didSelectAssetGroup:(ALAssetsGroup *)group;
@end

// list browser controller
@interface GCImageListBrowserController : GCImageBrowserController {
    
}

@property (nonatomic, readonly) NSArray *assetsGroups;
@property (nonatomic, assign) id<GCImageListBrowserDelegate> listBrowserDelegate;
@property (nonatomic, assign) BOOL showDisclosureIndicator;

@end

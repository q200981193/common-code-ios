//
//  GCImageGridBrowserController.h
//  GUI Cocoa Common Code Library for iOS
//
//  Created by Caleb Davenport on 2/1/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import "GCImageBrowserController.h"

@class GCImageGridBrowserController;
@class ALAssetsGroup;

// grid browser delegate
@protocol GCImageGridBrowserDelegate <NSObject>
@required
- (void)gridBrowser:(GCImageGridBrowserController *)controller didSelectAssets:(NSSet *)assetURLs;
@end

// grid browser
@interface GCImageGridBrowserController : GCImageBrowserController {
@private
    
    // assets
    NSString *assetsGroupIdentifier;
    NSMutableSet *selectedAssetURLs;
    NSArray *allAssets;
    ALAssetsGroup *assetsGroup;
    
    // button items
    UIBarButtonItem *_selectButtonItem;
    UIBarButtonItem *_actionButtonItem;
    UIBarButtonItem *_cancelButtonItem;
    
}

// view properties
@property (nonatomic, assign) BOOL editing;
@property (nonatomic, assign) id<GCImageGridBrowserDelegate> delegate;
@property (nonatomic, assign) CGFloat assetViewPadding;
@property (nonatomic, assign) NSUInteger numberOfAssetsPerRow;

@property (nonatomic, readonly) UIBarButtonItem *selectButtonItem;
@property (nonatomic, readonly) UIBarButtonItem *actionButtonItem;
@property (nonatomic, readonly) UIBarButtonItem *cancelButtonItem;

- (id)initWithAssetsGroupIdentifier:(NSString *)groupIdentifier;

@end

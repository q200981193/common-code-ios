//
//  GCImageGridViewController.h
//  GUI Cocoa Common Code Library for iOS
//
//  Created by Caleb Davenport on 2/1/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import "GCImageBrowserController.h"

@interface GCImageGridBrowserController : GCImageBrowserController {
@private
    
    // button items
    UIBarButtonItem *_selectButtonItem;
    UIBarButtonItem *_actionButtonItem;
    UIBarButtonItem *_cancelButtonItem;
    
    // view geometry
    CGFloat assetSpacing;
    NSUInteger numberOfAssetsPerRow;
    
    // other stuff
    ALAssetsGroupType groupTypes;
    ALAssetsLibrary *assetsLibrary;
    NSMutableSet *selectedAssets;
    NSString *assetsGroupIdentifier;
    NSString *baseTitle;
    NSArray *allAssets;
    
}

@property (nonatomic, readonly) UIBarButtonItem *selectButtonItem;
@property (nonatomic, readonly) UIBarButtonItem *actionButtonItem;
@property (nonatomic, readonly) UIBarButtonItem *cancelButtonItem;

- (id)initWithAssetsGroupTypes:(ALAssetsGroupType)types title:(NSString *)title groupID:(NSString *)groupID;

@end

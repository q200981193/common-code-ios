//
//  GCImageBrowserController.h
//  GUI Cocoa Common Code Library for iOS
//
//  Created by Caleb Davenport on 3/26/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

// image browser data source
@protocol GCImageBrowserDelegate <NSObject>
@required
- (ALAssetsFilter *)assetsFilter;
- (NSString *)actionTitle;
- (BOOL)actionEnabled;
- (ALAssetsLibraryAssetForURLResultBlock)actionBlock;
@end

// image browser controller
@interface GCImageBrowserController : NSObject {
    
}

// title that a view controller can display
@property (nonatomic, copy) NSString *title;

// browser delegate
@property (nonatomic, assign) id<GCImageBrowserDelegate> browserDelegate;

// library to read data from
@property (nonatomic, readonly) ALAssetsLibrary *assetsLibrary;

// view that a view controller can display
@property (nonatomic, retain) IBOutlet UIView *view;

/*
 designated initializer
 loads associated nib
 */
- (id)initWithAssetsLibrary:(ALAssetsLibrary *)library;

/*
 reload data
 the default implementation of this method does nothing
 you do not need to call super
 */
- (void)reloadData;

@end

//
//  GCImageBrowserController.h
//  GUI Cocoa Common Code Library for iOS
//
//  Created by Caleb Davenport on 3/26/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ALAssetsLibrary;
@class ALAssetsFilter;

// image browser data source
@protocol GCImageBrowserDataSource <NSObject>
@required
- (ALAssetsLibrary *)assetsLibrary;
- (ALAssetsFilter *)assetsFilter;
- (NSString *)selectActionTitle;
- (BOOL)selectActionEnabled;
@end

// image browser controller
@interface GCImageBrowserController : NSObject <UITableViewDelegate, UITableViewDataSource> {
    
}

// properties
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) id<GCImageBrowserDataSource> dataSource;

// internal
@property (nonatomic, retain) IBOutlet UIView *view;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;

/*
 designated initializer
 loads associated nib
 */
- (id)init;

/*
 reload data
 the default implementation of this method does nothing
 you do not need to call super
 */
- (void)reloadData;

@end

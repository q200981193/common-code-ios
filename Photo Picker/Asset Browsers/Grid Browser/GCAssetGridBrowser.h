/*
 
 Copyright (C) 2011 GUI Cocoa, LLC.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */

#import "GCAssetTableBrowser.h"
#import "GCImageGridCell.h"

// grid browser delegate
@class GCAssetGridBrowser;
@protocol GCAssetGridBrowserDelegate <NSObject>
@required
- (void)gridBrowser:(GCAssetGridBrowser *)controller didSelectAssets:(NSSet *)assetURLs;
@end

// grid browser
@interface GCAssetGridBrowser : GCAssetTableBrowser <GCImageGridCellDelegate> {
@private
    
    // assets
    NSString *assetsGroupIdentifier;
    NSString *assetsGroupTitle;
    NSMutableSet *selectedAssetURLs;
    NSArray *allAssets;
    
    // button items
    UIBarButtonItem *_actionButtonItem;
    UIBarButtonItem *_cancelButtonItem;
    
}

// view properties
@property (nonatomic, assign) BOOL editing;
@property (nonatomic, assign) id<GCAssetGridBrowserDelegate> gridBrowserDelegate;
@property (nonatomic, assign) CGFloat assetViewPadding;
@property (nonatomic, assign) NSUInteger numberOfAssetsPerRow;

// button accessors
@property (nonatomic, readonly) UIBarButtonItem *actionButtonItem;
@property (nonatomic, readonly) UIBarButtonItem *cancelButtonItem;

// initializer
- (id)initWithImagePickerController:(GCImagePickerController *)picker groupIdentifier:(NSString *)identifier;

@end

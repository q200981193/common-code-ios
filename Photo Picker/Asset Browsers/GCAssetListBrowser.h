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

@class GCAssetListBrowser;

@protocol GCAssetListBrowserDelegate <NSObject>
@required
- (void)listBrowser:(GCAssetListBrowser *)controller didSelectAssetGroup:(ALAssetsGroup *)group;
@end

@interface GCAssetListBrowser : GCAssetTableBrowser {
    
}

// all groups shown by the table
@property (nonatomic, readonly) NSArray *groups;

// enable or disable disclosure indicators in table
@property (nonatomic, assign) BOOL showDisclosureIndicators;

// get callback for group selection
@property (nonatomic, assign) id<GCAssetListBrowserDelegate> listBrowserDelegate;

@end

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

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef void (^GCImagePickerControllerActionBlock)(ALAssetsLibrary *library, NSURL *URL);

// image browser data source
@protocol GCImageBrowserDelegate <NSObject>
@required
- (ALAssetsFilter *)assetsFilter;
- (NSString *)actionTitle;
- (BOOL)actionEnabled;
- (GCImagePickerControllerActionBlock)actionBlock;
- (ALAssetsLibraryAccessFailureBlock)failureBlock;
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
 */
- (void)reloadData;

@end

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

#import "GCImagePickerController.h"

#import "GCIPViewController.h"

@implementation GCIPViewController

@synthesize imagePickerController=_imagePickerController;

- (void)setImagePickerController:(NSObject<GCImagePickerController> *)controller {
    if (_imagePickerController) {
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(asdf)
         name:ALAssetsLibraryChangedNotification
         object:controller.assetsLibrary];
        [controller
         addObserver:self
         forKeyPath:@"assetsFilter"
         options:0
         context:0];
    }
    else {
        [[NSNotificationCenter defaultCenter]
         removeObserver:self
         name:ALAssetsLibraryChangedNotification
         object:_imagePickerController.assetsLibrary];
        [_imagePickerController
         removeObserver:self
         forKeyPath:@"assetsFilter"];
    }
    _imagePickerController = controller;
}
- (void)assetsLibraryChanged:(NSNotification *)notif {
    [self reloadAssets];
}
- (void)reloadAssets {
    if ([self isViewLoaded]) {
        
        // do reloading here
        
    }
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.imagePickerController && [keyPath isEqualToString:@"assetsFilter"]) {
        [self reloadAssets];
    }
}
- (void)dealloc {
    self.imagePickerController = nil;
    [super dealloc];
}

@end

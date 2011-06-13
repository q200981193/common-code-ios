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

#import "GCAssetBrowser.h"
#import "GCImagePickerController.h"

@implementation GCAssetBrowser

@synthesize title;
@synthesize view;
@synthesize picker=_picker;

- (id)initWithImagePickerController:(GCImagePickerController *)picker {
    self = [super init];
    if (self) {
        if (!picker && !picker.assetsLibrary) {
            [NSException
             raise:NSInvalidArgumentException
             format:@"%@ the provided picker and its must not be nil",
             NSStringFromSelector(_cmd)];
            [self release];
            return nil;
        }
        else {
            _picker = [picker retain];
            [[NSNotificationCenter defaultCenter]
             addObserver:self
             selector:@selector(libraryDidChange:)
             name:ALAssetsLibraryChangedNotification
             object:self.picker.assetsLibrary];
            [self.picker
             addObserver:self
             forKeyPath:@"mediaTypes"
             options:0
             context:0];
        }
    }
    return self;
}
- (void)dealloc {
    [self.picker
     removeObserver:self
     forKeyPath:@"mediaTypes"];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:ALAssetsLibraryChangedNotification
     object:self.picker.assetsLibrary];
    [_picker release];
    _picker = nil;
    self.view = nil;
    self.title = nil;
    [super dealloc];
}
- (void)reloadData {
    // subclasses should override this
}
- (void)libraryDidChange:(NSNotification *)notif {
    [self reloadData];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.picker && [keyPath isEqualToString:@"mediaTypes"]) {
        [self reloadData];
    }
}

@end

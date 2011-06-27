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

#import <AssetsLibrary/AssetsLibrary.h>

#import "GCIPViewController_Phone.h"

@implementation GCIPViewController_Phone

@synthesize actionBlock=_actionBlock;
@synthesize actionTitle=_actionTitle;
@synthesize actionEnabled=_actionEnabled;

- (id)initWithRootViewController:(UIViewController *)controller {
    GCIPGroupPickerController *picker = [[GCIPGroupPickerController alloc] initWithNibName:nil bundle:nil];
    picker.imagePickerController = self;
    picker.pickerDelegate = self;
    self = [super initWithRootViewController:picker];
    [picker release];
    return self;
}
- (void)dealloc {
    [library release];
    library = nil;
    self.actionBlock = nil;
    self.actionTitle = nil;
    [super dealloc];
}
- (void)groupPicker:(GCIPGroupPickerController *)picker didPickGroup:(ALAssetsGroup *)group {
    GCIPAssetPickerController *assetPicker = [[GCIPAssetPickerController alloc] initWithNibName:nil bundle:nil];
    assetPicker.imagePickerController = self;
    assetPicker.groupIdentifier = [group valueForProperty:ALAssetsGroupPropertyPersistentID];
    [self pushViewController:assetPicker animated:YES];
    [assetPicker release];
}
#pragma mark - accessors
- (ALAssetsLibrary *)assetsLibrary {
    if (library == nil) {
        library = [[ALAssetsLibrary alloc] init];
    }
    return library;
}

@end

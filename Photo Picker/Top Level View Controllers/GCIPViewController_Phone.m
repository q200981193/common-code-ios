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

#import "GCIPViewController_Phone.h"

@interface GCIPViewController_Phone (private)
- (void)reloadChildren;
@end

@implementation GCIPViewController_Phone (private)
- (void)reloadChildren {
    for (UIViewController *controller in self.viewControllers) {
        if ([controller isKindOfClass:[GCIPViewController class]]) {
            [(GCIPViewController *)controller reloadAssets];
        }
    }
}
@end

@implementation GCIPViewController_Phone

@synthesize actionBlock=_actionBlock;
@synthesize actionTitle=_actionTitle;
@synthesize actionEnabled=_actionEnabled;
@synthesize assetsFilter=_assetsFilter;

#pragma mark - object methods
- (id)initWithRootViewController:(UIViewController *)controller {
    GCIPGroupPickerController *picker = [[GCIPGroupPickerController alloc] initWithNibName:nil bundle:nil];
    picker.imagePickerController = self;
    picker.pickerDelegate = self;
    self = [super initWithRootViewController:picker];
    if (self) {
        library = [[ALAssetsLibrary alloc] init];
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(assetsLibraryDidChange:)
         name:ALAssetsLibraryChangedNotification
         object:library];
    }
    [picker release];
    return self;
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:ALAssetsLibraryChangedNotification
     object:library];
    [library release];
    library = nil;
    self.actionBlock = nil;
    self.actionTitle = nil;
    self.assetsFilter = nil;
    [super dealloc];
}

#pragma mark - picker delegate
- (void)groupPicker:(GCIPGroupPickerController *)picker didPickGroup:(ALAssetsGroup *)group {
    GCIPAssetPickerController *assetPicker = [[GCIPAssetPickerController alloc] initWithNibName:nil bundle:nil];
    assetPicker.imagePickerController = self;
    assetPicker.groupIdentifier = [group valueForProperty:ALAssetsGroupPropertyPersistentID];
    [self pushViewController:assetPicker animated:YES];
    [assetPicker release];
}

#pragma mark - notifications
- (void)assetsLibraryDidChange:(NSNotification *)notif {
    [self reloadChildren];
}
         
#pragma mark - accessors
- (void)setAssetsFilter:(ALAssetsFilter *)filter {
    [self reloadChildren];
}

@end

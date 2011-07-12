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

@interface GCIPViewController_Phone ()
@property (nonatomic, readwrite, retain) ALAssetsLibrary *assetsLibrary;
@end

@interface GCIPViewController_Phone (private)
- (void)reloadChildren;
@end

@implementation GCIPViewController_Phone (private)
- (void)reloadChildren {
    [self.viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[GCIPViewController class]]) {
            [(GCIPViewController *)obj reloadAssets];
        }
    }];
}
@end

@implementation GCIPViewController_Phone

@synthesize actionBlock         = __actionBlock;
@synthesize actionTitle         = __actionTitle;
@synthesize actionEnabled       = __actionEnabled;
@synthesize assetsFilter        = __assetsFilter;
@synthesize assetsLibrary       = __assetsLibrary;

#pragma mark - object methods
- (id)initWithRootViewController:(UIViewController *)controller {
    GCIPGroupPickerController *picker = [[GCIPGroupPickerController alloc] initWithNibName:nil bundle:nil];
    picker.imagePickerController = self;
    picker.pickerDelegate = self;
    self = [super initWithRootViewController:picker];
    if (self) {
        
        // create library
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        self.assetsLibrary = library;
        [library release];
        
        // sign up for notifs
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(assetsLibraryDidChange:)
         name:ALAssetsLibraryChangedNotification
         object:self.assetsLibrary];
        
    }
    [picker release];
    return self;
}
- (void)dealloc {
    
    // clear notifs
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:ALAssetsLibraryChangedNotification
     object:self.assetsLibrary];
    
    // clear properties
    self.assetsLibrary = nil;
    self.actionBlock = nil;
    self.actionTitle = nil;
    self.assetsFilter = nil;
    
    // super
    [super dealloc];
    
}

#pragma mark - picker delegate
- (void)groupPicker:(GCIPGroupPickerController *)picker didPickGroup:(ALAssetsGroup *)group {
    NSString *identifier = [group valueForProperty:ALAssetsGroupPropertyPersistentID];
    GCIPAssetPickerController *assetPicker = [[GCIPAssetPickerController alloc] initWithAssetsGroupIdentifier:identifier];
    assetPicker.imagePickerController = self;
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

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

#import "GCImageListBrowserController.h"
#import "GCImagePickerController.h"

@implementation GCImageListBrowserController

@synthesize showDisclosureIndicators=_showDisclosureIndicators;
@synthesize assetsGroups=_assetsGroups;
@synthesize listBrowserDelegate=_listBrowserDelegate;

#pragma mark - object lifecycle
- (id)initWithAssetsLibrary:(ALAssetsLibrary *)library {
	self = [super initWithAssetsLibrary:library];
	if (self) {
		self.title = GCImagePickerControllerLocalizedString(@"PHOTO_LIBRARY");
        self.showDisclosureIndicators = NO;
	}
	return self;
}
- (void)dealloc {
    [self willChangeValueForKey:@"assetsGroups"];
	[_assetsGroups release];
	_assetsGroups = nil;
    [self didChangeValueForKey:@"assetsGroups"];
    [super dealloc];
}

#pragma mark - object methods
- (void)reloadData {
    
    // kvo
    [self willChangeValueForKey:@"assetsGroups"];
    
    // release old groups
    [_assetsGroups release];
    
    // setup containers for new groups
    __block NSUInteger count = 0;
    __block ALAssetsGroup *savedPhotos = nil;
    ALAssetsFilter *filter = [self.browserDelegate assetsFilter];
    NSMutableArray *albums = [NSMutableArray array];
    NSMutableArray *faces = [NSMutableArray array];
    NSMutableArray *events = [NSMutableArray array];
    
    // load gruops
	[self.assetsLibrary
	 enumerateGroupsWithTypes:ALAssetsGroupAll
	 usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
		 if (group == nil) {
			 *stop = YES;
             NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:count];
             if (savedPhotos != nil) {
                 [array addObject:savedPhotos];
                 [savedPhotos release];
                 savedPhotos = nil;
             }
             [array addObjectsFromArray:albums];
             [array addObjectsFromArray:events];
             [array addObjectsFromArray:faces];
             _assetsGroups = array;
		 }
		 else {
             [group setAssetsFilter:filter];
             if ([group numberOfAssets] > 0) {
                 count++;
                 NSNumber *type = [group valueForProperty:ALAssetsGroupPropertyType];
                 ALAssetsGroupType groupType = [type unsignedIntegerValue];
                 if (groupType == ALAssetsGroupSavedPhotos) {
                     savedPhotos = [group retain];
                 }
                 else if (groupType == ALAssetsGroupAlbum) {
                     [albums addObject:group];
                 }
                 else if (groupType == ALAssetsGroupFaces) {
                     [faces addObject:group];
                 }
                 else if (groupType == ALAssetsGroupEvent) {
                     [events addObject:group];
                 }
             }
		 }
	 }
	 failureBlock:^(NSError *error){
         _assetsGroups = [[NSArray alloc] init];
         [self.browserDelegate failureBlock](error);
     }];
    
    // wait
    while (self.assetsGroups == nil) {
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.1, NO);
    }
    
    // reload view
    [self.tableView reloadData];
    self.tableView.hidden = ([self.assetsGroups count] == 0);
    
    // kvo
    [self didChangeValueForKey:@"assetsGroups"];
    
}

#pragma mark - table view
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60.0;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.assetsGroups count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = (self.showDisclosureIndicators) ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    }
    ALAssetsGroup *group = [self.assetsGroups objectAtIndex:indexPath.row];
	cell.textLabel.text = [group valueForProperty:ALAssetsGroupPropertyName];
	cell.imageView.image = [UIImage imageWithCGImage:[group posterImage]];
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [group numberOfAssets]];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ALAssetsGroup *group = [self.assetsGroups objectAtIndex:indexPath.row];
    [self.listBrowserDelegate listBrowser:self didSelectAssetGroup:group];
}

@end

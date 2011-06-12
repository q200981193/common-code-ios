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

#import "GCAssetListBrowser.h"
#import "GCImagePickerControllerDefines.h"

#import "ALAssetsLibrary+CustomAccessors.h"

@implementation GCAssetListBrowser

@synthesize groups=_groups;
@synthesize showDisclosureIndicators=_showDisclosureIndicators;
@synthesize listBrowserDelegate=_listBrowserDelegate;

#pragma mark - object methods
- (id)initWithAssetsLibrary:(ALAssetsLibrary *)library {
	self = [super initWithAssetsLibrary:library];
	if (self) {
		self.title = GCImagePickerControllerLocalizedString(@"PHOTO_LIBRARY");
        self.showDisclosureIndicators = NO;
	}
	return self;
}
- (void)dealloc {
    [self willChangeValueForKey:@"groups"];
	[_groups release];
	_groups = nil;
    [self didChangeValueForKey:@"groups"];
    [super dealloc];
}
- (void)reloadData {
    
    // kvo
    [self willChangeValueForKey:@"groups"];
    
    // get new gruops
    NSError *error;
    [_groups release];
    _groups = [self.assetsLibrary
               assetGroupsWithTypes:ALAssetsGroupAll
               assetsFilter:[self.browserDelegate assetsFilter]
               error:&error];
    [_groups retain];
    
    // kvo
    [self didChangeValueForKey:@"groups"];
    
    // reload view
    [self.tableView reloadData];
    self.tableView.hidden = ([_groups count] == 0);
    
}

#pragma mark - table view
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60.0;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.groups count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = (self.showDisclosureIndicators) ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    }
    ALAssetsGroup *group = [self.groups objectAtIndex:indexPath.row];
	cell.textLabel.text = [group valueForProperty:ALAssetsGroupPropertyName];
	cell.imageView.image = [UIImage imageWithCGImage:[group posterImage]];
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [group numberOfAssets]];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ALAssetsGroup *group = [self.groups objectAtIndex:indexPath.row];
    [self.listBrowserDelegate listBrowser:self didSelectAssetGroup:group];
}

@end

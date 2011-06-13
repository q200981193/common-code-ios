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

#import "GCAssetGridBrowser.h"
#import "GCAssetGridAssetView.h"
#import "GCImagePickerController.h"

#import "ALAssetsLibrary+CustomAccessors.h"

#define kNumberOfSpaces (self.numberOfAssetsPerRow + 1)
#define kHorizontalSpaceSize (self.assetViewPadding * kNumberOfSpaces)
#define kTileSize \
    floorf((self.tableView.bounds.size.width - kHorizontalSpaceSize) / self.numberOfAssetsPerRow)
#define kRowHeight (kTileSize + self.assetViewPadding)

#pragma mark - private methods
@interface GCAssetGridBrowser (private)
- (void)updateTitle;
@end
@implementation GCAssetGridBrowser (private)
- (void)updateTitle {
    NSUInteger count = [selectedAssetURLs count];
    if (count == 0) {
        self.title = assetsGroupTitle;
    }
    else if (count == 1) {
        self.title = GCImagePickerControllerLocalizedString(@"PHOTO_COUNT_SINGLE");
    }
    else {
        self.title = [NSString localizedStringWithFormat:GCImagePickerControllerLocalizedString(@"PHOTO_COUNT_MULTIPLE"), count];
    }
}
@end

@implementation GCAssetGridBrowser

@synthesize editing=_editing;
@synthesize gridBrowserDelegate=_gridBrowserDelegate;
@synthesize numberOfAssetsPerRow=_numberOfAssetsPerRow;
@synthesize assetViewPadding=_assetViewPadding;
@synthesize actionButtonItem=_actionButtonItem;
@synthesize cancelButtonItem=_cancelButtonItem;

#pragma mark - object lifecycle
- (id)initWithImagePickerController:(GCImagePickerController *)picker groupIdentifier:(NSString *)identifier {
    self = [super initWithImagePickerController:picker];
	if (self) {
        
        // cancel button
        _cancelButtonItem = [[UIBarButtonItem alloc]
                             initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                             target:self
                             action:@selector(cancel)];
        
        // action button
        _actionButtonItem = [[UIBarButtonItem alloc]
                             initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                             target:self
                             action:@selector(action)];
        
        // save group
        assetsGroupIdentifier = [identifier copy];
        
        // table view
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        // tap recognizer
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(tableDidReceiveTap:)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        [self.tableView addGestureRecognizer:tap];
        [tap release];
        
	}
	return self;
}
- (void)dealloc {
    
    // cancel button
    [_cancelButtonItem release];
    _cancelButtonItem = nil;
    
    // action button
    [_actionButtonItem release];
    _actionButtonItem = nil;
    
    // other crap
    [allAssets release];
    allAssets = nil;
    [selectedAssetURLs release];
    selectedAssetURLs = nil;
    [assetsGroupIdentifier release];
    assetsGroupIdentifier = nil;
    [assetsGroupTitle release];
    assetsGroupTitle = nil;
    
    // super
    [super dealloc];
    
}

#pragma mark - object methods
- (void)reloadData {
    
    // release old assets
    [allAssets release];
    allAssets = nil;
    [assetsGroupTitle release];
    assetsGroupTitle = nil;
    
    // get assets
    ALAssetsGroup *group = nil;
    NSError *error = nil;
    allAssets = [self.picker.assetsLibrary
                 assetsInGroupWithIdentifier:assetsGroupIdentifier
                 filter:self.picker.assetsFilter
                 group:&group
                 error:&error];
    
    // retain new stuff
    assetsGroupTitle = [[group valueForProperty:ALAssetsGroupPropertyName] copy];
    [allAssets retain];
    
    // reload view
    [self.tableView reloadData];
    self.tableView.hidden = ([allAssets count] == 0);
    [self updateTitle];
    
}

#pragma mark - accessors
- (void)setEditing:(BOOL)editing {
    if (_editing == editing) {
        return;
    }
    _editing = editing;
    if (_editing) {
        selectedAssetURLs = [[NSMutableSet alloc] init];
        self.actionButtonItem.enabled = ([selectedAssetURLs count] > 0);
    }
    else {
        [selectedAssetURLs release];
        selectedAssetURLs = nil;
        self.actionButtonItem.enabled = NO;
    }
    [self updateTitle];
    [self.tableView reloadData];
}

#pragma mark - button actions
- (void)cancel {
    self.editing = NO;
}
- (void)action {
//    NSSet *URLs = [selectedAssetURLs copy];
//    GCImagePickerControllerActionBlock block = [[self.browserDelegate actionBlock] copy];
//    for (NSURL *URL in URLs) {
//        block(self.assetsLibrary, URL);
//    }
//    [block release];
//    [URLs release];
//    self.editing = NO;
}

#pragma mark - table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
	return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) { return kRowHeight + self.assetViewPadding; }
    else { return kRowHeight; }
}
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = [allAssets count];
	NSInteger rows = count / self.numberOfAssetsPerRow;
	if (count % self.numberOfAssetsPerRow > 0) { rows++; }
	return rows;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // create cell
	static NSString *CellIdentifier = @"Cell";
	GCImageGridCell *cell = (GCImageGridCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
        
        // setup cell
		cell = [[[GCImageGridCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
        
        // add subviews
        for (NSInteger i = 0; i < self.numberOfAssetsPerRow; i++) {
            GCImageGridAssetView *assetView = [[GCImageGridAssetView alloc] initWithFrame:CGRectZero];
            assetView.tag = 100 + i;
            [cell.contentView addSubview:assetView];
            [assetView release];
        }
        
	}
	
    // configure cell
	NSInteger start = indexPath.row * self.numberOfAssetsPerRow;
	for (NSInteger i = start; i < start + self.numberOfAssetsPerRow; i++) {
        NSInteger tag = 100 + (i % self.numberOfAssetsPerRow);
        GCImageGridAssetView *assetView = (GCImageGridAssetView *)[cell.contentView viewWithTag:tag];
        if (i < [allAssets count]) {
            ALAsset *asset = [allAssets objectAtIndex:i];
            NSURL *defaultURL = [[asset defaultRepresentation] url];
            assetView.asset = asset;
            assetView.selected = [selectedAssetURLs containsObject:defaultURL];
        }
        else {
            assetView.asset = nil;
        }
        [assetView setNeedsLayout];
	}
	
	return cell;
}

#pragma mark - gestures
- (void)tableDidReceiveTap:(UITapGestureRecognizer *)gesture {
    
    // do stuff
    CGPoint location = [gesture locationInView:gesture.view];
    NSUInteger column = MIN(location.x / (self.assetViewPadding + kTileSize), self.numberOfAssetsPerRow - 1);
    NSUInteger row = location.y / kRowHeight;
    NSUInteger index = row * self.numberOfAssetsPerRow + column;
    if (index < [allAssets count]) {
        ALAsset *asset = [allAssets objectAtIndex:index];
        ALAssetRepresentation *representation = [asset defaultRepresentation];
        NSURL *defaultURL = [representation url];
        if (!self.editing) {
            self.editing = YES;
        }
        if ([selectedAssetURLs containsObject:defaultURL]) {
            [selectedAssetURLs removeObject:defaultURL];
        }
        else {
            [selectedAssetURLs addObject:defaultURL];
        }
        if ([selectedAssetURLs count] == 0) {
            self.editing = NO;
            return;
        }
        [self updateTitle];
        self.actionButtonItem.enabled = ([selectedAssetURLs count] > 0);
        NSArray *paths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:row inSection:0]];
        [self.tableView reloadRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationNone];
        
    }
}

#pragma mark - grid cell delegate
- (void)positionView:(UIView *)view forIndex:(NSUInteger)index {
    CGFloat tileSize = kTileSize;
    CGPoint origin = CGPointZero;
    origin.x = (self.assetViewPadding * (index + 1)) + (tileSize * index);
    origin.y = (view.superview.bounds.size.height - self.assetViewPadding - tileSize);
    view.frame = CGRectMake(origin.x, origin.y, tileSize, tileSize);
}

@end

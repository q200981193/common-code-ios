//
//  GCImageGridBrowserController.m
//  GUI Cocoa Common Code Library for iOS
//
//  Created by Caleb Davenport on 2/1/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

#import "GCImagePickerController.h"
#import "GCImageGridBrowserController.h"
#import "GCImageGridAssetView.h"
#import "GCImageGridCell.h"

#define kNumberOfSpaces (self.numberOfAssetsPerRow + 1)
#define kHorizontalSpaceSize (self.assetViewPadding * kNumberOfSpaces)
#define kTileSize \
    floorf((self.tableView.bounds.size.width - kHorizontalSpaceSize) / self.numberOfAssetsPerRow)
#define kRowHeight (kTileSize + self.assetViewPadding)

@interface GCImageGridBrowserController (private)
- (void)updateTitle;
@end

@implementation GCImageGridBrowserController (private)
- (void)updateTitle {
    if (self.editing) {
        NSUInteger count = [selectedAssetURLs count];
        if (count == 0) {
            self.title = GCImagePickerControllerLocalizedString(@"SELECT_ITEMS");
        }
        else if (count == 1) {
            self.title = GCImagePickerControllerLocalizedString(@"PHOTO_COUNT_SINGLE");
        }
        else {
            self.title = [NSString localizedStringWithFormat:GCImagePickerControllerLocalizedString(@"PHOTO_COUNT_MULTIPLE"), count];
        }
    }
    else {
        NSString *groupTitle = [assetsGroup valueForProperty:ALAssetsGroupPropertyName];
        self.title = groupTitle;
    }
}
@end

@implementation GCImageGridBrowserController

@synthesize editing=_editing;
@synthesize delegate=_delegate;
@synthesize numberOfAssetsPerRow=_numberOfAssetsPerRow;
@synthesize assetViewPadding=_assetViewPadding;

@synthesize selectButtonItem=_selectButtonItem;
@synthesize actionButtonItem=_actionButtonItem;
@synthesize cancelButtonItem=_cancelButtonItem;

#pragma mark - object lifecycle
- (id)initWithAssetsGroupIdentifier:(NSString *)groupIdentifier {
    self = [super init];
	if (self) {

        // view geometry
//        if (GC_IS_IPAD) {
//            assetSpacing = 10.0;
//            numberOfAssetsPerRow = 6;
//        }
//        else {
//            assetSpacing = 4.0;
//            numberOfAssetsPerRow = 4;
//        }
        
        // select button
        [self willChangeValueForKey:@"selectButtonItem"];
        _selectButtonItem = [[UIBarButtonItem alloc]
                             initWithImage:[UIImage imageNamed:@"GCImagePickerControllerMultiSelect"]
                             style:UIBarButtonItemStyleBordered
                             target:self
                             action:@selector(selectAction)];
        [self didChangeValueForKey:@"selectButtonItem"];
        
        // cancel button
        [self willChangeValueForKey:@"cancelButtonItem"];
        _cancelButtonItem = [[UIBarButtonItem alloc]
                             initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                             target:self
                             action:@selector(cancelAction)];
        [self didChangeValueForKey:@"cancelButtonItem"];
        
        // save group
        assetsGroupIdentifier = [groupIdentifier copy];
        
        // table view
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
	}
	return self;
}
- (void)dealloc {
    
    // select button
    [self willChangeValueForKey:@"selectButtonItem"];
    [_selectButtonItem release];
    _selectButtonItem = nil;
    [self didChangeValueForKey:@"selectButtonItem"];
    
    // cancel button
    [self willChangeValueForKey:@"cancelButtonItem"];
    [_cancelButtonItem release];
    _cancelButtonItem = nil;
    [self didChangeValueForKey:@"cancelButtonItem"];
    
    // other crap
    [allAssets release];
    allAssets = nil;
    [selectedAssetURLs release];
    selectedAssetURLs = nil;
    [assetsGroupIdentifier release];
    assetsGroupIdentifier = nil;
    [assetsGroup release];
    assetsGroup = nil;
    
    [super dealloc];
    
}

#pragma mark - object methods
- (void)reloadData {
    
    // release old assets
    [allAssets release];
    allAssets = nil;
    [assetsGroup release];
    assetsGroup = nil;
    
    // prepare to get assets
    ALAssetsFilter *filter = [self.dataSource assetsFilter];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    ALAssetsGroupEnumerationResultsBlock block = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
		if (result != nil) { [array addObject:result]; }
	};
    
    // get new assets
    [[self.dataSource assetsLibrary]
     enumerateGroupsWithTypes:ALAssetsGroupAll
     usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
         if (group == nil) {
             *stop = YES;
             allAssets = array;
         }
         else {
             NSString *groupID = [group valueForProperty:ALAssetsGroupPropertyPersistentID];
             if ([groupID isEqualToString:assetsGroupIdentifier]) {
                 [group setAssetsFilter:filter];
                 [group enumerateAssetsUsingBlock:block];
                 assetsGroup = [group retain];
                 *stop = YES;
             }
         }
     }
     failureBlock:^(NSError *error){
         allAssets = [[NSArray alloc] init];
         //self.failureBlock(error);
     }];
    
    // wait for it to finish
    while (allAssets == nil) {
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.1, NO);
    }
    
    // reload view
    [self.tableView reloadData];
    self.tableView.hidden = ([allAssets count] == 0);
    [self updateTitle];
    if (assetsGroup && [allAssets count] > self.numberOfAssetsPerRow) {
        NSNumber *groupTypeNumber = [assetsGroup valueForProperty:ALAssetsGroupPropertyType];
        ALAssetsGroupType groupType = [groupTypeNumber unsignedIntegerValue];
        if (groupType == ALAssetsGroupSavedPhotos) {
            NSUInteger row = MAX(0, [self.tableView numberOfRowsInSection:0] - 1);
            NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:0];
            [self.tableView
             scrollToRowAtIndexPath:path
             atScrollPosition:UITableViewScrollPositionBottom
             animated:NO];
        }
    }
    
}

#pragma mark - accessors
- (void)setEditing:(BOOL)editing {
    if (_editing == editing) {
        return;
    }
    [self willChangeValueForKey:@"editing"];
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
    [self.tableView reloadData];
    [self didChangeValueForKey:@"editing"];
}

#pragma mark - button actions
- (void)selectAction {
    self.editing = YES;
}
- (void)cancel {
    self.editing = NO;
}
- (void)action {
    [self.delegate gridBrowser:self didSelectAssets:selectedAssetURLs];
//    for (NSURL *URL in [selectedAssetURLs allObjects]) {
//        [assetsLibrary
//         assetForURL:URL
//         resultBlock:self.actionBlock
//         failureBlock:^(NSError *error) {
//             GC_LOG_ERROR(@"%@", error);
//         }];
//    }
    self.editing = NO;
}

#pragma mark - table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
	return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kRowHeight;
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
        
        // add subviews
        for (NSInteger i = 0; i < self.numberOfAssetsPerRow; i++) {
            GCImageGridAssetView *assetView = [[GCImageGridAssetView alloc] initWithFrame:CGRectZero];
            assetView.tag = 100 + i;
            [cell.contentView addSubview:assetView];
            [assetView release];
        }
        
        // layout block
        __block CGFloat blockPadding = self.assetViewPadding;
        __block NSUInteger blockCount = self.numberOfAssetsPerRow;
        __block UIView *blockView = tableView;
        cell.layoutBlock = ^(UIView *view, NSUInteger index) {
            CGFloat totalSpaceSize = (blockCount + 1) * blockPadding;
            CGFloat tileSize = (blockView.bounds.size.width - totalSpaceSize) / blockCount;
            CGFloat originX = (blockPadding * (index + 1)) + (tileSize * index);
            CGRect viewFrame = CGRectMake(originX, 0.0, tileSize, tileSize);
            view.frame = viewFrame;
        };
        
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
- (void)tableDidReceiveTap:(UITapGestureRecognizer *)tap {
    UIView *tapView = tap.view;
    CGPoint location = [tap locationInView:tapView];
    NSUInteger column = MIN(location.x / (self.assetViewPadding + kTileSize), self.numberOfAssetsPerRow - 1);
    NSUInteger row = location.y / kRowHeight;
    NSUInteger index = row * self.numberOfAssetsPerRow + column;
    if (index < [allAssets count]) {
        ALAsset *asset = [allAssets objectAtIndex:index];
        ALAssetRepresentation *representation = [asset defaultRepresentation];
        NSURL *defaultURL = [representation url];
        
        // edit mode
        if (self.editing) {
            if ([selectedAssetURLs containsObject:defaultURL]) {
                [selectedAssetURLs removeObject:defaultURL];
            }
            else {
                [selectedAssetURLs addObject:defaultURL];
            }
            [self updateTitle];
            self.actionButtonItem.enabled = ([selectedAssetURLs count] > 0);
            NSArray *paths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:row inSection:0]];
            [self.tableView reloadRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationNone];
            
        }
        
        // not edit mode
        else {
            
        }
        
    }
}

@end

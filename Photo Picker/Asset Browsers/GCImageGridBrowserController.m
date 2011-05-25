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

#define kNumberOfSpaces (self.numberOfAssetsPerRow + 1)
#define kHorizontalSpaceSize (self.assetViewPadding * kNumberOfSpaces)
#define kTileSize \
    floorf((self.tableView.bounds.size.width - kHorizontalSpaceSize) / self.numberOfAssetsPerRow)
#define kRowHeight (kTileSize + self.assetViewPadding)

@interface GCImageGridBrowserController (private)
- (void)updateTitle;
- (void)updateActionButtonItem;
@end

@implementation GCImageGridBrowserController (private)
- (void)updateTitle {
    NSUInteger count = [selectedAssetURLs count];
    if (count == 0) {
        NSString *groupTitle = [assetsGroup valueForProperty:ALAssetsGroupPropertyName];
        self.title = groupTitle;
    }
    else if (count == 1) {
        self.title = GCImagePickerControllerLocalizedString(@"PHOTO_COUNT_SINGLE");
    }
    else {
        self.title = [NSString localizedStringWithFormat:GCImagePickerControllerLocalizedString(@"PHOTO_COUNT_MULTIPLE"), count];
    }
}
- (void)updateActionButtonItem {
    [self willChangeValueForKey:@"cancelButtonItem"];
    [_actionButtonItem release];
    NSString *title = [self.browserDelegate actionTitle];
    if (title == nil) {
        _actionButtonItem = nil;
    }
    else {
        _actionButtonItem = [[UIBarButtonItem alloc]
                             initWithTitle:title
                             style:UIBarButtonItemStyleDone
                             target:self
                             action:@selector(actionAction)];
        _actionButtonItem.enabled = ([selectedAssetURLs count] > 0);
    }
    [self didChangeValueForKey:@"cancelButtonItem"];
}
@end

@implementation GCImageGridBrowserController

@synthesize editing=_editing;
@synthesize gridBrowserDelegate=_gridBrowserDelegate;
@synthesize numberOfAssetsPerRow=_numberOfAssetsPerRow;
@synthesize assetViewPadding=_assetViewPadding;
@synthesize actionButtonItem=_actionButtonItem;
@synthesize cancelButtonItem=_cancelButtonItem;

#pragma mark - object lifecycle
- (id)initWithAssetsLibrary:(ALAssetsLibrary *)library groupIdentifier:(NSString *)identifier {
    self = [super initWithAssetsLibrary:library];
	if (self) {
        
        // cancel button
        _cancelButtonItem = [[UIBarButtonItem alloc]
                             initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                             target:self
                             action:@selector(cancelAction)];
        
        // action button
        [self updateActionButtonItem];
        
        // save group
        assetsGroupIdentifier = [identifier copy];
        
        // table view
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(tableDidReceiveTap:)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        [self.tableView addGestureRecognizer:tap];
        [tap release];
//        UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc]
//                                               initWithTarget:self
//                                               action:@selector(tableDidReceiveLongPress:)];
//        press.minimumPressDuration = 0.7;
//        press.numberOfTouchesRequired = 1;
//        [self.tableView addGestureRecognizer:press];
//        [press release];
        
	}
	return self;
}
- (void)dealloc {
    
    // cancel button
    [_cancelButtonItem release];
    _cancelButtonItem = nil;
    
    // action button
    [self willChangeValueForKey:@"actionButtonItem"];
    [_actionButtonItem release];
    _actionButtonItem = nil;
    [self didChangeValueForKey:@"actionButtonItem"];
    
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
    ALAssetsFilter *filter = [self.browserDelegate assetsFilter];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    ALAssetsGroupEnumerationResultsBlock block = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
		if (result != nil) { [array addObject:result]; }
	};
    
    // get new assets
    [self.assetsLibrary
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
         [self.browserDelegate failureBlock](error);
     }];
    
    // wait for it to finish
    while (allAssets == nil) {
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.1, NO);
    }
    
    // reload view
    [self.tableView reloadData];
    self.tableView.hidden = ([allAssets count] == 0);
    [self updateTitle];
    [self updateActionButtonItem];
//    if (assetsGroup) {
//        NSNumber *groupTypeNumber = [assetsGroup valueForProperty:ALAssetsGroupPropertyType];
//        ALAssetsGroupType groupType = [groupTypeNumber unsignedIntegerValue];
//        if (groupType == ALAssetsGroupSavedPhotos) {
//            NSUInteger row = MAX(0, [self.tableView numberOfRowsInSection:0] - 1);
//            NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:0];
//            [self.tableView
//             scrollToRowAtIndexPath:path
//             atScrollPosition:UITableViewScrollPositionBottom
//             animated:NO];
//            NSLog(@"%@", NSStringFromCGRect(self.tableView.frame));
//        }
//    }
    
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
- (void)cancelAction {
    self.editing = NO;
}
- (void)actionAction {
    NSSet *URLs = [selectedAssetURLs copy];
    ALAssetsLibraryAssetForURLResultBlock block = [[self.browserDelegate actionBlock] copy];
    for (NSURL *URL in URLs) {
        [self.assetsLibrary
         assetForURL:URL
         resultBlock:block
         failureBlock:^(NSError *error) {
             // TODO: error case
         }];
    }
    [block release];
    [URLs release];
    self.editing = NO;
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
- (void)tableDidReceiveLongPress:(UILongPressGestureRecognizer *)gesture {
    
//    // log
//    GC_LOG_INFO(@"");
//    
//    // do stuff
//    CGPoint location = [gesture locationInView:gesture.view];
//    NSUInteger column = MIN(location.x / (self.assetViewPadding + kTileSize), self.numberOfAssetsPerRow - 1);
//    NSUInteger row = location.y / kRowHeight;
//    NSUInteger index = row * self.numberOfAssetsPerRow + column;
//    if (index < [allAssets count]) {
//        CGRect cellRect = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
//        CGFloat tileSize = kTileSize;
//        CGPoint origin = CGPointZero;
//        origin.x = (self.assetViewPadding * (index + 1)) + (tileSize * index);
//        origin.y = (cellRect.size.height - self.assetViewPadding - tileSize);
//        CGRect tileRect = CGRectMake(origin.x, origin.y + cellRect.origin.y, tileSize, tileSize);
//        [[UIMenuController sharedMenuController] setTargetRect:tileRect inView:self.view];
//        [[UIMenuController sharedMenuController] setTargetRect:CGRectZero inView:self.view];
//        UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:@"Copy" action:@selector(copyAsset)];
//        [[UIMenuController sharedMenuController] setMenuItems:<#(NSArray *)#>];
//        [[UIMenuController sharedMenuController] setMenuVisible:YES animated:YES];
//    }
    
}
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

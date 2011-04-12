//
//  GCImageGridViewController.m
//  GUI Cocoa Common Code Library for iOS
//
//  Created by Caleb Davenport on 2/1/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import "GCImageGridBrowserController.h"
#import "GCImageGridAssetView.h"
#import "GCImageGridCell.h"
#import "GCImageSlideshowController.h"
#import "GCImagePreviewController.h"

#define kNumberOfSpaces (numberOfAssetsPerRow + 1)
#define kHorizontalSpaceSize (assetSpacing * kNumberOfSpaces)
#define kTileSize \
    floorf((self.tableView.bounds.size.width - kHorizontalSpaceSize) / numberOfAssetsPerRow)
#define kRowHeight (kTileSize + assetSpacing)

@interface GCImageGridBrowserController (private)
- (void)reloadAssets;
- (void)updateTitle;
- (void)cleanup;
@end

@implementation GCImageGridBrowserController (private)
- (void)reloadAssets {
    [allAssets release];
    allAssets = nil;
    ALAssetsFilter *filter = [self assetsFilter];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    ALAssetsGroupEnumerationResultsBlock block = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
		if (result != nil) { [array addObject:result]; }
	};
    [assetsLibrary
     enumerateGroupsWithTypes:groupTypes
     usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
         if (group == nil) {
             *stop = YES;
             allAssets = array;
             [self.tableView reloadData];
             if (groupTypes == ALAssetsGroupSavedPhotos) {
                 NSUInteger row = MAX(0, [self.tableView numberOfRowsInSection:0] - 1);
                 NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:0];
                 [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:NO];
             }
             self.tableView.hidden = ([allAssets count] == 0);
         }
         else {
             if (assetsGroupIdentifier == nil) {
                 [group setAssetsFilter:filter];
                 [group enumerateAssetsUsingBlock:block];
             }
             else {
                 NSString *groupID = [group valueForProperty:ALAssetsGroupPropertyPersistentID];
                 if ([groupID isEqualToString:assetsGroupIdentifier]) {
                     [group setAssetsFilter:filter];
                     [group enumerateAssetsUsingBlock:block];
                 }
             }
         }
     }
     failureBlock:^(NSError *error){
         allAssets = [[NSArray alloc] init];
         self.failureBlock(error);
     }];
    while (allAssets == nil) {
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.1, NO);
    }
}
- (void)updateTitle {
    if (self.editing) {
        NSUInteger count = [selectedAssets count];
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
        self.title = baseTitle;
    }
}
- (void)cleanup {
    
    [self willChangeValueForKey:@"selectButtonItem"];
    [_selectButtonItem release];
    _selectButtonItem = nil;
    [self didChangeValueForKey:@"selectButtonItem"];
    
    [self willChangeValueForKey:@"actionButtonItem"];
    [_actionButtonItem release];
    _actionButtonItem = nil;
    [self didChangeValueForKey:@"actionButtonItem"];
    
    [self willChangeValueForKey:@"cancelButtonItem"];
    [_cancelButtonItem release];
    _cancelButtonItem = nil;
    [self didChangeValueForKey:@"cancelButtonItem"];
    
    [allAssets release];
    allAssets = nil;
    
    [selectedAssets release];
    selectedAssets = nil;
    
}
@end

@implementation GCImageGridBrowserController

@synthesize selectButtonItem=_selectButtonItem;
@synthesize actionButtonItem=_actionButtonItem;
@synthesize cancelButtonItem=_cancelButtonItem;

#pragma mark - object lifecycle
- (id)initWithAssetsGroupTypes:(ALAssetsGroupType)types title:(NSString *)title groupID:(NSString *)groupID {
    self = [super init];
	if (self) {
        
        if (GC_IS_IPAD) {
            assetSpacing = 10.0;
            numberOfAssetsPerRow = 6;
        }
        else {
            assetSpacing = 4.0;
            numberOfAssetsPerRow = 4;
        }
        assetsLibrary = [[ALAssetsLibrary alloc] init];
        groupTypes = types;
        baseTitle = [title copy];
        assetsGroupIdentifier = [groupID copy];
        
		[self updateTitle];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(assetsLibraryDidChange:)
         name:ALAssetsLibraryChangedNotification
         object:assetsLibrary];
        
        [self
         addObserver:self
         forKeyPath:@"mediaTypes"
         options:0
         context:nil];
        
	}
	return self;
}
- (void)dealloc {
    
    [self cleanup];
    
    [self removeObserver:self forKeyPath:@"mediaTypes"];
    
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:ALAssetsLibraryChangedNotification
     object:assetsLibrary];
    
    [assetsLibrary release];
    assetsLibrary = nil;
    
	[baseTitle release];
	baseTitle = nil;
    
	[assetsGroupIdentifier release];
	assetsGroupIdentifier = nil;
    
    [super dealloc];
    
}

#pragma mark - view lifecycle
- (void)viewDidLoad {
	[super viewDidLoad];
    
    if (self.actionEnabled && self.actionBlock && self.actionTitle) {
        
        // multi select button
        [self willChangeValueForKey:@"selectButtonItem"];
        UIImage *selectImage = [UIImage imageNamed:@"GCImagePickerControllerMultiSelect"];
        _selectButtonItem = [[UIBarButtonItem alloc]
                             initWithImage:selectImage
                             style:UIBarButtonItemStyleBordered
                             target:self
                             action:@selector(select)];
        [self didChangeValueForKey:@"selectButtonItem"];
        
        // action button item
        [self willChangeValueForKey:@"actionButtonItem"];
        _actionButtonItem = [[UIBarButtonItem alloc]
                             initWithTitle:self.actionTitle
                             style:UIBarButtonItemStyleDone
                             target:self
                             action:@selector(action)];
        [self didChangeValueForKey:@"actionButtonItem"];
        self.navigationItem.rightBarButtonItem = self.selectButtonItem;
        
    }
    
    [self willChangeValueForKey:@"cancelButtonItem"];
    _cancelButtonItem = [[UIBarButtonItem alloc]
                         initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                         target:self
                         action:@selector(cancel)];
    [self didChangeValueForKey:@"cancelButtonItem"];
	
    // table view
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // gestures
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self
                                             action:@selector(tableDidReceiveTap:)];
	tapRecognizer.numberOfTapsRequired = 1;
	tapRecognizer.numberOfTouchesRequired = 1;
	[self.tableView addGestureRecognizer:tapRecognizer];
    [tapRecognizer release];
	
	// inset
	UIEdgeInsets insets = self.tableView.contentInset;
    insets.top += assetSpacing;
    self.tableView.contentInset = insets;
    
    // reload
    [self reloadAssets];
    
}
- (void)viewDidUnload {
    [super viewDidUnload];
    [self cleanup];
}
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (!GC_IS_IPAD) {
		[[UIApplication sharedApplication]
		 setStatusBarStyle:UIStatusBarStyleBlackTranslucent
		 animated:animated];
	}
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self && [keyPath isEqualToString:@"mediaTypes"]) {
        [self reloadAssets];
    }
}

#pragma mark - notifications
- (void)assetsLibraryDidChange:(NSNotification *)notification {
    [self reloadAssets];
}

#pragma mark - button actions
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    if (editing) {
        selectedAssets = [[NSMutableSet alloc] init];
        self.navigationItem.rightBarButtonItem = self.cancelButtonItem;
        self.navigationItem.leftBarButtonItem = self.actionButtonItem;
        self.actionButtonItem.enabled = ([selectedAssets count] > 0);
    }
    else {
        [selectedAssets release];
        selectedAssets = nil;
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = self.selectButtonItem;
    }
    [self updateTitle];
	[self.tableView reloadData];
}
- (void)done {
	[self dismissModalViewControllerAnimated:YES];
}
- (void)select {
    self.editing = YES;
}
- (void)cancel {
    self.editing = NO;
}
- (void)action {
    for (NSURL *URL in [selectedAssets allObjects]) {
        [assetsLibrary
         assetForURL:URL
         resultBlock:self.actionBlock
         failureBlock:^(NSError *error) {
             GC_LOG_ERROR(@"%@", error);
         }];
    }
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
	NSInteger rows = count / numberOfAssetsPerRow;
	if (count % numberOfAssetsPerRow > 0) { rows++; }
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
        for (NSInteger i = 0; i < numberOfAssetsPerRow; i++) {
            GCImageGridAssetView *assetView = [[GCImageGridAssetView alloc] initWithFrame:CGRectZero];
            assetView.tag = 100 + i;
            [cell.contentView addSubview:assetView];
            [assetView release];
        }
        
        // layout block
        __block CGFloat blockPadding = assetSpacing;
        __block NSUInteger blockCount = numberOfAssetsPerRow;
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
	NSInteger start = indexPath.row * numberOfAssetsPerRow;
	for (NSInteger i = start; i < start + numberOfAssetsPerRow; i++) {
        NSInteger tag = 100 + (i % numberOfAssetsPerRow);
        GCImageGridAssetView *assetView = (GCImageGridAssetView *)[cell.contentView viewWithTag:tag];
        if (i < [allAssets count]) {
            ALAsset *asset = [allAssets objectAtIndex:i];
            NSURL *defaultURL = [[asset defaultRepresentation] url];
            assetView.asset = asset;
            assetView.selected = [selectedAssets containsObject:defaultURL];
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
    NSUInteger column = MIN(location.x / (assetSpacing + kTileSize), numberOfAssetsPerRow - 1);
    NSUInteger row = location.y / kRowHeight;
    NSUInteger index = row * numberOfAssetsPerRow + column;
    if (index < [allAssets count]) {
        ALAsset *asset = [allAssets objectAtIndex:index];
        ALAssetRepresentation *representation = [asset defaultRepresentation];
        NSURL *defaultURL = [representation url];
        
        // edit mode
        if (self.editing) {
            if ([selectedAssets containsObject:defaultURL]) {
                [selectedAssets removeObject:defaultURL];
            }
            else {
                [selectedAssets addObject:defaultURL];
            }
            [self updateTitle];
            self.actionButtonItem.enabled = ([selectedAssets count] > 0);
            NSArray *paths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:row inSection:0]];
            [self.tableView reloadRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationNone];
            
        }
        
        // not edit mode
        else {
            
        }
        
    }
}

@end

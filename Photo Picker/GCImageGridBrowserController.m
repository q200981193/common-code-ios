//
//  GCImageGridViewController.m
//  GUI Cocoa Common Code Library for iOS
//
//  Created by Caleb Davenport on 2/1/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import "GCImageGridBrowserController.h"
#import "GCImageGridAssetView.h"
#import "GCImageSlideshowController.h"

#define kSpaceSize 4.0
#define kTileSize ((self.view.bounds.size.width - (kSpaceSize * 5.0)) / 4.0)
#define kRowHeight (kTileSize + kSpaceSize)

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
    ALAssetsGroupEnumerationResultsBlock block = ^(ALAsset *result, NSUInteger index, BOOL *stop){
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
                 NSUInteger row = MIN(0, [self.tableView numberOfRowsInSection:0] - 1);
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
}
- (void)updateTitle {
    NSUInteger count = [selectedAssets count];
    if (count == 0) {
        self.title = baseTitle;
    }
    else if (count == 1) {
        self.title = GCImagePickerControllerLocalizedString(@"PHOTO_COUNT_SINGLE");
    }
    else {
        self.title = [NSString localizedStringWithFormat:GCImagePickerControllerLocalizedString(@"PHOTO_COUNT_MULTIPLE"), count];
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

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self) {
        if ([keyPath isEqualToString:@"mediaTypes"]) {
            [self reloadAssets];
        }
    }
}

#pragma mark - notifications
- (void)assetsLibraryDidChange:(NSNotification *)notification {
    [self reloadAssets];
    while (allAssets == nil) {
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.1, NO);
    }
}

#pragma mark - view lifecycle
- (void)viewDidLoad {
	[super viewDidLoad];
    
    [self willChangeValueForKey:@"selectButtonItem"];
    UIImage *selectImage = [UIImage imageNamed:@"GCImagePickerControllerMultiSelect"];
    _selectButtonItem = [[UIBarButtonItem alloc]
                         initWithImage:selectImage
                         style:UIBarButtonItemStyleBordered
                         target:self
                         action:@selector(select)];
    [self didChangeValueForKey:@"selectButtonItem"];
    
    [self willChangeValueForKey:@"actionButtonItem"];
    _actionButtonItem = [[UIBarButtonItem alloc]
                         initWithTitle:self.actionTitle
                         style:UIBarButtonItemStyleDone
                         target:self
                         action:@selector(action)];
    [self didChangeValueForKey:@"actionButtonItem"];
    
    [self willChangeValueForKey:@"cancelButtonItem"];
    _cancelButtonItem = [[UIBarButtonItem alloc]
                         initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                         target:self
                         action:@selector(cancel)];
    [self didChangeValueForKey:@"cancelButtonItem"];
	
    // table view
    self.tableView.hidden = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // gestures
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self
                                             action:@selector(tableDidReceiveTap:)];
	tapRecognizer.numberOfTapsRequired = 1;
	tapRecognizer.numberOfTouchesRequired = 1;
	[self.tableView addGestureRecognizer:tapRecognizer];
    [tapRecognizer release];
    
	// buttons
	if ([self gc_isRootViewController]) {
		UIBarButtonItem *item = [[UIBarButtonItem alloc]
                                 initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                 target:self
                                 action:@selector(done)];
		self.navigationItem.leftBarButtonItem = item;
		[item release];
	}
    if (self.actionEnabled && self.actionBlock && self.actionTitle) {
        self.navigationItem.rightBarButtonItem = self.selectButtonItem;
    }
	
	// offset
	UIEdgeInsets insets = self.tableView.contentInset;
    insets.top += kSpaceSize;
    self.tableView.contentInset = insets;
    
    // assets
    [self reloadAssets];
    while (allAssets == nil) {
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.1, NO);
    }
    
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

#pragma mark - button actions
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    if (editing) {
        selectedAssets = [[NSMutableSet alloc] init];
        self.navigationItem.leftBarButtonItem = self.cancelButtonItem;
        self.navigationItem.rightBarButtonItem = self.actionButtonItem;
        self.actionButtonItem.enabled = ([selectedAssets count] > 0);
    }
    else {
        [selectedAssets release];
        selectedAssets = nil;
        if ([self gc_isRootViewController]) {
            UIBarButtonItem *item = [[UIBarButtonItem alloc]
                                     initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                     target:self
                                     action:@selector(done)];
            self.navigationItem.leftBarButtonItem = item;
            [item release];
        }
        else {
            self.navigationItem.leftBarButtonItem = nil;
        }
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
    NSSet *assetURLs = [selectedAssets copy];
    for (NSURL *url in assetURLs) {
        [assetsLibrary
         assetForURL:url
         resultBlock:self.actionBlock
         failureBlock:self.failureBlock];
    }
    [assetURLs release];
    if ([self gc_isRootViewController]) {
        [self dismissModalViewControllerAnimated:YES];
    }
    else {
        [self cancel];
    }
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
	NSInteger rows = count / 4;
	if (count % 4 > 0) { rows++; }
	return rows;
}
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // create cell
	static NSString * CellIdentifier = @"Cell";
	UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		CGFloat size = kTileSize;
		for (NSInteger i = 0; i < 4; i++) {
            CGRect frame = CGRectMake(i * size + kSpaceSize * (i + 1.0), 0, size, size);
            GCImageGridAssetView *assetView = [[GCImageGridAssetView alloc] initWithFrame:frame];
            assetView.tag = 100 + i;
            [cell.contentView addSubview:assetView];
            [assetView release];
		}
	}
	
    // configure cell
	NSInteger start = indexPath.row * 4;
	for (NSInteger i = start; i < start + 4; i++) {
        NSInteger tag = 100 + (i % 4);
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
	}
	
	return cell;
}

#pragma mark - gestures
- (void)tableDidReceiveTap:(UITapGestureRecognizer *)tap {
    if (selectedAssets) {
        
        // setup variables
        UITableView *tap_view = self.tableView;
        CGPoint location = [tap locationInView:tap_view];
        CGFloat loc_x = kSpaceSize, loc_y = kSpaceSize;
        CGFloat tile_size = kTileSize;
        CGFloat view_width = tap_view.contentSize.width;
        CGFloat view_height = tap_view.contentSize.height;
        NSUInteger index_x = 0, index_y = 0;
        
        // find values
        while (loc_x < view_width) {
            CGFloat next_loc = loc_x + tile_size;
            if (next_loc > location.x) {
                loc_x = CGFLOAT_MAX;
            }
            else {
                loc_x = next_loc + kSpaceSize;
                index_x++;
            }
        }
        while (loc_y < view_height) {
            CGFloat next_loc = loc_y + tile_size;
            if (next_loc > location.y) {
                loc_y = CGFLOAT_MAX;
            }
            else {
                loc_y = next_loc + kSpaceSize;
                index_y++;
            }
        }
        
        // calculate index
        NSUInteger index = index_y * 4 + index_x;
        if (index < [allAssets count]) {
            
            // update model
            ALAsset *asset = [allAssets objectAtIndex:index];
            NSURL *defaultURL = [[asset defaultRepresentation] url];
            if ([selectedAssets containsObject:defaultURL]) {
                [selectedAssets removeObject:defaultURL];
            }
            else {
                [selectedAssets addObject:defaultURL];
            }
            
            // update views
            [self updateTitle];
            self.actionButtonItem.enabled = ([selectedAssets count] > 0);
            NSArray *paths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:index_y inSection:0]];
            [self.tableView reloadRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationNone];
            
        }
    }
#if 0
    else {
        GCImageSlideshowController *slideshow = [[GCImageSlideshowController alloc] initWithAssets:allAssets];
        [self.navigationController pushViewController:slideshow animated:YES];
        [slideshow release];
    }
#endif
}

@end

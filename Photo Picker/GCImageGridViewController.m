//
//  GCImageGridViewController.m
//  GUI Cocoa Common Code Library for iOS
//
//  Created by Caleb Davenport on 2/1/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import "GCImageGridViewController.h"
#import "GCImageGridAssetView.h"

#define kSpaceSize 4.0
#define kTileSize ((self.view.bounds.size.width - (kSpaceSize * 5.0)) / 4.0)
#define kRowHeight (kTileSize + kSpaceSize)
#define kButtonEnabled ([selectedAssets count] > 0)

@interface GCImageGridViewController (private)
- (void)reloadAssets;
- (void)updateTitle;
@end

@implementation GCImageGridViewController (private)
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
                 NSUInteger row = [self.tableView numberOfRowsInSection:0] - 1;
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
     failureBlock:self.failureBlock];
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
@end

@implementation GCImageGridViewController

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
	}
	return self;
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:ALAssetsLibraryChangedNotification
     object:assetsLibrary];
    [assetsLibrary release];
    assetsLibrary = nil;
	[baseTitle release];
	baseTitle = nil;
	[selectedAssets release];
	selectedAssets = nil;
	[assetsGroupIdentifier release];
	assetsGroupIdentifier = nil;
	[allAssets release];
	allAssets = nil;
    [super dealloc];	
}

#pragma mark - notifications
- (void)assetsLibraryDidChange:(NSNotification *)notification {
    [self reloadAssets];
}

#pragma mark - view lifecycle
- (void)viewDidLoad {
	[super viewDidLoad];
	
    // table view
    self.tableView.hidden = YES;
    self.tableView.rowHeight = kRowHeight;
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
	UIBarButtonItem *item;
	if ([self gc_isRootViewController] && !GC_IS_IPAD) {
		item = [[UIBarButtonItem alloc]
				initWithBarButtonSystemItem:UIBarButtonSystemItemDone
				target:self
				action:@selector(done)];
		self.navigationItem.leftBarButtonItem = item;
		[item release];
	}
    if (self.actionEnabled && self.actionBlock && self.actionTitle) {
        item = [[UIBarButtonItem alloc]
                initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                target:self
                action:@selector(action)];
        self.navigationItem.rightBarButtonItem = item;
        [item release];
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
    [allAssets release];
    allAssets = nil;
    [selectedAssets release];
    selectedAssets = nil;
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
- (void)done {
	[self dismissModalViewControllerAnimated:YES];
}
- (void)action {
	
	// buttons
	UIBarButtonItem *item;
	item = [[UIBarButtonItem alloc]
			initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
			target:self
			action:@selector(cancel)];
	self.navigationItem.leftBarButtonItem = item;
	[item release];
	item = [[UIBarButtonItem alloc]
			initWithTitle:self.actionTitle
			style:UIBarButtonItemStyleDone
			target:self
			action:@selector(upload)];
	item.enabled = kButtonEnabled;
	self.navigationItem.rightBarButtonItem = item;
	[item release];
	
	// self
    if (GC_IS_IPAD) {
        self.modalInPopover = YES;
    }
    
    // selected
    selectedAssets = [[NSMutableSet alloc] init];
	
}
- (void)cancel {
	
	// buttons
	UIBarButtonItem *item;
	item = [[UIBarButtonItem alloc]
			initWithBarButtonSystemItem:UIBarButtonSystemItemAction
			target:self
			action:@selector(action)];
	self.navigationItem.rightBarButtonItem = item;
	[item release];
	if ([self gc_isRootViewController] && !GC_IS_IPAD) {
		item = [[UIBarButtonItem alloc]
				initWithBarButtonSystemItem:UIBarButtonSystemItemDone
				target:self
				action:@selector(done)];
		self.navigationItem.leftBarButtonItem = item;
		[item release];
	}
	else {
		self.navigationItem.leftBarButtonItem = nil;
	}
	
	// selected
    [selectedAssets release];
    selectedAssets = nil;
	
	// update views
    if (GC_IS_IPAD) {
        self.modalInPopover = NO;
    }
	[self updateTitle];
	[self.tableView reloadData];
	
}
- (void)upload {
    NSSet *assetURLs = [selectedAssets copy];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSURL *url in assetURLs) {
            [assetsLibrary
             assetForURL:url
             resultBlock:^(ALAsset *asset){
                 self.actionBlock(asset);
             }
             failureBlock:^(NSError *error){
                 GC_LOG_ERROR(@"%@", error);
             }];
        }
	});
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
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = [allAssets count];
	NSInteger rows = count / 4;
	if (count % 4 > 0) {
        rows++;
	}
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
    if (selectedAssets != nil) {
        
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
            self.navigationItem.rightBarButtonItem.enabled = kButtonEnabled;
            NSArray *paths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:index_y inSection:0]];
            [self.tableView reloadRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationNone];
            
        }
    }
}

@end

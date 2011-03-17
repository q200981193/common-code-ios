//
//  GCImageGridViewController.m
//  GUI Cocoa Common Code Library for iOS
//
//  Created by Caleb Davenport on 2/1/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "GCImageGridViewController.h"

#define kSpaceSize 4.0
#define kTileSize ((self.view.bounds.size.width - (kSpaceSize * 5.0)) / 4.0)
#define kCellSize (kTileSize + kSpaceSize)
#define kButtonEnabled ([selectedAssets count] > 0)

@interface GCImageGridViewController (private)
- (void)updateTitle;
@end

@implementation GCImageGridViewController (private)
- (void)updateTitle {
    NSUInteger count = [selectedAssets count];
    if (count == 0) {
        self.title = baseTitle;
    }
    else if (count == 1) {
        self.title = NSLocalizedString(@"PHOTO_COUNT_SINGLE", @"");
    }
    else {
        self.title = [NSString localizedStringWithFormat:NSLocalizedString(@"PHOTO_COUNT_MULTIPLE", @""), count];
    }
}
@end

@implementation GCImageGridViewController

#pragma mark - object lifecycle
- (id)initWithAssetsGroupTypes:(ALAssetsGroupType)aTypes title:(NSString *)aTitle {
    self = [super init];
	if (self) {
        assetsLibrary = [[ALAssetsLibrary alloc] init];
        groupTypes = aTypes;
        baseTitle = [aTitle copy];
		[self updateTitle];
	}
	return self;
}
- (id)initWithAssetsGroup:(ALAssetsGroup *)group {
	self = [super init];
	if (self) {
        assetsGroup = [group retain];
        baseTitle = [[group valueForProperty:ALAssetsGroupPropertyName] copy];
		[self updateTitle];
	}
	return self;
}
- (void)dealloc {
    [assetsLibrary release];
    assetsLibrary = nil;
	[baseTitle release];
	baseTitle = nil;
	[selectedAssets release];
	selectedAssets = nil;
	[assetsGroup release];
	assetsGroup = nil;
	[allAssets release];
	allAssets = nil;
    [super dealloc];	
}

#pragma mark - view lifecycle
- (void)viewDidLoad {
	[super viewDidLoad];
	
    // table view
    self.tableView.hidden = YES;
    self.tableView.rowHeight = kCellSize;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
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
	
	// setup container
    NSInteger count = 0;
    if (assetsGroup != nil) { count = [assetsGroup numberOfAssets]; }
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:count];

    // declare enumeration block
	ALAssetsGroupEnumerationResultsBlock block = ^(ALAsset *result, NSUInteger index, BOOL *stop){
		if (result == nil) {
			*stop = YES;
			allAssets = array;
            [self.tableView reloadData];
            self.tableView.hidden = ([allAssets count] == 0);
		}
		else {
			[array addObject:result];
		}
	};
	
    // load assets
	if (assetsGroup == nil) {
        ALAssetsFilter *filter = [self assetsFilter];
		[assetsLibrary
		 enumerateGroupsWithTypes:groupTypes
		 usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
			 [group setAssetsFilter:filter];
			 [group enumerateAssetsUsingBlock:block];
		 }
		 failureBlock:self.failureBlock];
	}
	else {
		[assetsGroup enumerateAssetsUsingBlock:block];
	}
    
}
- (void)viewDidUnload {
    [super viewDidUnload];
    [allAssets release];
    allAssets = nil;
    [selectedAssets release];
    selectedAssets = nil;
    tapRecognizer = nil;
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
	
	// gestures
	tapRecognizer = [[UITapGestureRecognizer alloc]
                     initWithTarget:self
                     action:@selector(tableDidReceiveTap:)];
	tapRecognizer.numberOfTapsRequired = 1;
	tapRecognizer.numberOfTouchesRequired = 1;
	[self.tableView addGestureRecognizer:tapRecognizer];
    [tapRecognizer release];
	
	// self
    if (GC_IS_IPAD) {
        self.modalInPopover = YES;
    }
	
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
	
	// gestures
	[self.tableView removeGestureRecognizer:tapRecognizer];
	tapRecognizer = nil;
	
	// selected
	[selectedAssets removeAllObjects];
	
	// update views
	self.modalInPopover = NO;
	[self updateTitle];
	[self.tableView reloadData];
	
}
- (void)upload {
//	NSSet *localAssets = [NSSet setWithSet:selectedAssets];
//	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//		for (ALAsset *asset in localAssets) {
//			self.actionBlock(asset);
//		}
//	});
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
	static NSString * const CellIdentifier = @"Photo Cell";
	UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		CGFloat size = kTileSize;
		for (NSInteger i = 0; i < 4; i++) {
			UIImageView *imageView = [[UIImageView alloc] init];
			imageView.tag = i + 1;
			imageView.frame = CGRectMake(i * size + kSpaceSize * (i + 1.0), 0, size, size);
			CALayer *layer = [imageView layer];
			[layer setBorderColor:[[UIColor colorWithWhite:0.0 alpha:0.25] CGColor]];
			[layer setBorderWidth:1.0];
			[cell.contentView addSubview:imageView];
			[imageView release];
		}
	}
	
	NSInteger start = indexPath.row * 4;
	for (NSInteger i = start; i < start + 4; i++) {
		NSInteger base = 1 + (i % 4);
		UIImageView *tile = (UIImageView *)[cell.contentView viewWithTag:base];
		UIImageView *check = (UIImageView *)[cell.contentView viewWithTag:base + 4];
		UIImageView *video = (UIImageView *)[cell.contentView viewWithTag:base + 8];
		if (i < [allAssets count]) {
			ALAsset *asset = [allAssets objectAtIndex:i];
			NSString *type = [asset valueForProperty:ALAssetPropertyType];
			tile.hidden = NO;
			tile.image = [UIImage imageWithCGImage:[asset thumbnail]];
			if ([type isEqualToString:ALAssetTypeVideo]) {
				if (video == nil) {
					UIImage *image = [UIImage imageNamed:@"VideoOverlay"];
					image = [image stretchableImageWithLeftCapWidth:36 topCapHeight:0];
					video = [[UIImageView alloc] initWithImage:image];
					video.tag = base + 8;
					video.frame = CGRectMake(tile.frame.origin.x,
											 tile.frame.origin.y + tile.frame.size.height - image.size.height,
											 tile.frame.size.width,
											 image.size.height);
					[cell.contentView addSubview:video];
					[video release];
				}
				video.hidden = NO;
			}
			else {
				video.hidden = YES;
			}
			if ([selectedAssets containsObject:asset]) {
				if (check == nil) {
					check = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CheckGreen"]];
					check.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
					check.contentMode = UIViewContentModeBottomRight;
					check.tag = base + 4;
					check.frame = tile.frame;
					[cell.contentView addSubview:check];
					[check release];
				}
				check.hidden = NO;
			}
			else {
				check.hidden = YES;
			}
		}
		else {
			tile.hidden = YES;
			check.hidden = YES;
		}
		if (check != nil) {
			[cell.contentView bringSubviewToFront:check];
		}
	}
	
	return cell;
}

#pragma mark - gestures
- (void)tableDidReceiveTap:(UITapGestureRecognizer *)tap {
	
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
		if ([selectedAssets containsObject:asset]) {
			[selectedAssets removeObject:asset];
		}
		else {
			[selectedAssets addObject:asset];
		}
		
		// update views
		[self updateTitle];
		self.navigationItem.rightBarButtonItem.enabled = kButtonEnabled;
		NSArray *paths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:index_y inSection:0]];
		[self.tableView reloadRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationNone];
		
	}
	
}

@end

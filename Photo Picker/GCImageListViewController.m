//
//  QSAssetsGroupListController.m
//  QuickShot
//
//  Created by Caleb Davenport on 2/3/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import "GCImageListViewController.h"
#import "GCImageGridViewController.h"

@implementation GCImageListViewController

#pragma mark - object lifecycle
- (id)init {
	self = [super init];
	if (self) {
        assetsLibrary = [[ALAssetsLibrary alloc] init];
		self.title = NSLocalizedString(@"PHOTO_LIBRARY", @"");
	}
	return self;
}
- (void)dealloc {
    [assetsLibrary release];
    assetsLibrary = nil;
	[assetsGroups release];
	assetsGroups = nil;
    [super dealloc];
}

#pragma mark - view lifecycle
- (void)viewDidLoad {
	[super viewDidLoad];
	
    // table view
    self.tableView.hidden = YES;
    
	// button
	if (!GC_IS_IPAD) {
		UIBarButtonItem *item = [[UIBarButtonItem alloc]
								 initWithBarButtonSystemItem:UIBarButtonSystemItemDone
								 target:self
								 action:@selector(done)];
		self.navigationItem.leftBarButtonItem = item;
		[item release];
	}
	
	// get groups
    NSMutableArray *albums = [NSMutableArray array];
    NSMutableArray *faces = [NSMutableArray array];
    NSMutableArray *events = [NSMutableArray array];
    ALAssetsFilter *filter = [self assetsFilter];
    __block NSUInteger count = 0;
    __block ALAssetsGroup *savedPhotos = nil;
	[assetsLibrary
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
             assetsGroups = array;
             [self.tableView reloadData];
             self.tableView.hidden = ([assetsGroups count] == 0);
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
	 failureBlock:self.failureBlock];
	
}
- (void)viewDidUnload {
	[super viewDidUnload];
	[assetsGroups release];
	assetsGroups = nil;
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

#pragma mark - table view
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60.0;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
	return 1;
}
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	return [assetsGroups count];
}
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString * CellIdentifier = @"Cell";
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    ALAssetsGroup *group = [assetsGroups objectAtIndex:indexPath.row];
	cell.textLabel.text = [group valueForProperty:ALAssetsGroupPropertyName];
	cell.imageView.image = [UIImage imageWithCGImage:[group posterImage]];
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [group numberOfAssets]];
    return cell;
}
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	ALAssetsGroup *group = [assetsGroups objectAtIndex:indexPath.row];
	GCImagePickerController *browser = [[GCImageGridViewController alloc] initWithAssetsGroup:group];
    browser.actionBlock = self.actionBlock;
    browser.actionEnabled = self.actionEnabled;
    browser.actionTitle = self.actionTitle;
	[self.navigationController pushViewController:browser animated:YES];
    [browser release];
}

@end

//
//  QSAssetsGroupListController.m
//  QuickShot
//
//  Created by Caleb Davenport on 2/3/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#ifdef GC_ASSETS_LIBRARY

#import "GCAssetsGroupListViewController.h"
#import "GCPhotoGridViewController.h"

typedef void (^QSAssetsGroupsLoadCompletion) (NSArray *groups);

@interface GCAssetsGroupListViewController (private)
+ (void)loadAssetsGroupsFromLibrary:(ALAssetsLibrary *)library completion:(QSAssetsGroupsLoadCompletion)completion;
@end

@implementation GCAssetsGroupListViewController (private)
+ (void)loadAssetsGroupsFromLibrary:(ALAssetsLibrary *)library completion:(QSAssetsGroupsLoadCompletion)completion {
    
    /*
     __block ALAssetsGroup *camera;
     __block NSMutableArray *albums = [[NSMutableArray alloc] init];
     __block NSMutableArray *events = [[NSMutableArray alloc] init];
     __block NSMutableArray *faces = [[NSMutableArray alloc] init];
     [assetsLibrary
	 enumerateGroupsWithTypes:ALAssetsGroupAll
	 usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
     if (group == nil) {
     NSMutableArray *array = [[NSMutableArray alloc] init];
     if (camera != nil) {
     [array addObject:camera];
     [camera release];
     camera = nil;
     }
     [array addObjectsFromArray:albums];
     [array addObjectsFromArray:events];
     [array addObjectsFromArray:faces];
     [albums release];
     albums = nil;
     [events release];
     events = nil;
     [faces release];
     faces = nil;
     assetGrouops = array;
     self.tableView.hidden = ([assetGrouops count] == 0);
     [self.tableView reloadData];
     *stop = YES;
     }
     else {
     [group setAssetsFilter:[ALAssetsFilter allPhotos]];
     if ([group numberOfAssets] == 0) {
     return;
     }
     NSNumber *typeNumber = [group valueForProperty:ALAssetsGroupPropertyType];
     ALAssetsGroupType type = [typeNumber unsignedIntegerValue];
     if (type == ALAssetsGroupSavedPhotos) {
     camera = [group retain];
     }
     else if (type == ALAssetsGroupAlbum) {
     [albums addObject:group];
     }
     else if (type == ALAssetsGroupEvent) {
     [events addObject:group];
     }
     else if (type == ALAssetsGroupFaces) {
     [faces addObject:group];
     }
     }
	 }
	 failureBlock:^(NSError *error){
     GC_LOG_ERROR(@"%@", error);
	 }];
     */
    
    NSMutableArray *array = [NSMutableArray array];
    [library
     enumerateGroupsWithTypes:ALAssetsGroupAll
     usingBlock:^(ALAssetsGroup *group, BOOL *stop){
         if (group == nil) {
             completion(array);
             *stop = YES;
         }
         else {
             [array addObject:group];
         }
     }
     failureBlock:^(NSError *error){
         GC_LOG_ERROR(@"%@", error);
     }];
}
@end

@implementation GCAssetsGroupListViewController

#pragma mark - initialization
- (id)init {
	self = [super init];
	if (self) {
		assetsLibrary = [[ALAssetsLibrary alloc] init];
		self.title = NSLocalizedString(@"PHOTO_LIBRARY", @"");
	}
	return self;
}

#pragma mark - memory management
- (void)viewDidUnload {
	[super viewDidUnload];
	[assetsGrouops release];
	assetsGrouops = nil;
}
- (void)dealloc {
	[assetsLibrary release];
	assetsLibrary = nil;
	[assetsGrouops release];
	assetsGrouops = nil;
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
    [GCAssetsGroupListViewController
     loadAssetsGroupsFromLibrary:assetsLibrary
     completion:^(NSArray *groups){
         assetsGrouops = [groups retain];
     }];
	
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
	return [assetsGrouops count];
}
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString * const CellIdentifier = @"Cell";
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc]
				 initWithStyle:UITableViewCellStyleValue1
				 reuseIdentifier:CellIdentifier]
				autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    ALAssetsGroup *group = [assetsGrouops objectAtIndex:indexPath.row];
	cell.textLabel.text = [group valueForProperty:ALAssetsGroupPropertyName];
	cell.imageView.image = [UIImage imageWithCGImage:[group posterImage]];
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [group numberOfAssets]];
    return cell;
}
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	ALAssetsGroup *group = [assetsGrouops objectAtIndex:indexPath.row];
	GCPhotoGridViewController *browser = [[GCPhotoGridViewController alloc] initWithAssetsGroup:group];
    browser.actionBlock = self.actionBlock;
    browser.actionEnabled = self.actionEnabled;
    browser.actionTitle = self.actionTitle;
	[self.navigationController pushViewController:browser animated:YES];
    [browser release];
}

@end

#endif

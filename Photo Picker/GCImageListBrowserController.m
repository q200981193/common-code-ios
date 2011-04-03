//
//  QSAssetsGroupListController.m
//  GUI Cocoa Common Code Library for iOS
//
//  Created by Caleb Davenport on 2/3/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import "GCImageListBrowserController.h"
#import "GCImageGridBrowserController.h"

@interface GCImageListBrowserController (private)
- (void)reloadAssetsGroups;
@end

@implementation GCImageListBrowserController (private)
- (void)reloadAssetsGroups {
    [self willChangeValueForKey:@"assetsGroups"];
    [_assetsGroups release];
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
             _assetsGroups = array;
             [self didChangeValueForKey:@"assetsGroups"];
             [self.tableView reloadData];
             self.tableView.hidden = ([_assetsGroups count] == 0);
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
	 failureBlock:^(NSError *error){
         _assetsGroups = [[NSArray alloc] init];
         [self didChangeValueForKey:@"assetsGroups"];
         self.tableView.hidden = YES;
         self.failureBlock(error);
     }];
}
@end

@implementation GCImageListBrowserController

@synthesize selectedGroupBlock=_selectedGroupBlock;
@synthesize assetsGroups=_assetsGroups;

#pragma mark - object lifecycle
- (id)init {
	self = [super init];
	if (self) {
        assetsLibrary = [[ALAssetsLibrary alloc] init];
		self.title = GCImagePickerControllerLocalizedString(@"PHOTO_LIBRARY");
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
    [self removeObserver:self forKeyPath:@"mediaTypes"];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:ALAssetsLibraryChangedNotification
     object:assetsLibrary];
    [assetsLibrary release];
    assetsLibrary = nil;
	[_assetsGroups release];
	_assetsGroups = nil;
    self.selectedGroupBlock = nil;
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
	
	// groups
    [self reloadAssetsGroups];
    while (self.assetsGroups == nil) {
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.1, NO);
    }
	
}
- (void)viewDidUnload {
	[super viewDidUnload];
	[_assetsGroups release];
	_assetsGroups = nil;
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
    if (object == self) {
        if ([keyPath isEqualToString:@"mediaTypes"]) {
            [self reloadAssetsGroups];
            while (self.assetsGroups == nil) {
                CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.1, NO);
            }
        }
    }
}

#pragma mark - notifications
- (void)assetsLibraryDidChange:(NSNotification *)notif {
    [self reloadAssetsGroups];
    while (self.assetsGroups == nil) {
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.1, NO);
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
	return [self.assetsGroups count];
}
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString * CellIdentifier = @"Cell";
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = (self.selectedGroupBlock) ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;
    }
    ALAssetsGroup *group = [self.assetsGroups objectAtIndex:indexPath.row];
	cell.textLabel.text = [group valueForProperty:ALAssetsGroupPropertyName];
	cell.imageView.image = [UIImage imageWithCGImage:[group posterImage]];
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [group numberOfAssets]];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ALAssetsGroup *group = [self.assetsGroups objectAtIndex:indexPath.row];
    if (self.selectedGroupBlock == nil) {
        NSString *groupID = [group valueForProperty:ALAssetsGroupPropertyPersistentID];
        ALAssetsGroupType groupType = [[group valueForProperty:ALAssetsGroupPropertyType] unsignedIntegerValue];
        NSString *groupName = [group valueForProperty:ALAssetsGroupPropertyName];
        GCImagePickerController *browser = [[GCImageGridBrowserController alloc] initWithAssetsGroupTypes:groupType title:groupName groupID:groupID];
        browser.actionBlock = self.actionBlock;
        browser.actionEnabled = self.actionEnabled;
        browser.actionTitle = self.actionTitle;
        [self.navigationController pushViewController:browser animated:YES];
        [browser release];
    }
    else {
        self.selectedGroupBlock(group);
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

@end
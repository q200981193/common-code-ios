//
//  GCImageBrowserController_iPad.m
//  QuickShot
//
//  Created by Caleb Davenport on 3/31/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import "GCImageBrowserController_iPad.h"
#import "GCImageListBrowserController.h"
#import "GCImageGridBrowserController.h"

@interface GCImageBrowserController_iPad (private)
- (UIBarButtonItem *)popoverButtonItem;
- (UIBarButtonItem *)flexibleSpaceButtonItem;
- (void)updateToolbarItemsForOrientation:(UIInterfaceOrientation)orientation;
- (void)updateToolbarItems;
- (void)cleanup;
@end

@implementation GCImageBrowserController_iPad (private)
- (UIBarButtonItem *)popoverButtonItem {
    UIBarButtonItem *item = [[UIBarButtonItem alloc]
                             initWithTitle:self.listViewController.title
                             style:UIBarButtonItemStyleBordered
                             target:self
                             action:@selector(popoverAction:)];
    return [item autorelease];
}
- (UIBarButtonItem *)flexibleSpaceButtonItem {
    UIBarButtonItem *item = [[UIBarButtonItem alloc]
                             initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                             target:nil
                             action:nil];
    return [item autorelease];
}
- (void)updateToolbarItemsForOrientation:(UIInterfaceOrientation)orientation {
    NSMutableArray *array = [NSMutableArray array];
    if (self.gridViewController.editing) {
        if (self.gridViewController.cancelButtonItem) {
            [array addObject:self.gridViewController.cancelButtonItem];
        }
        [array addObject:[self flexibleSpaceButtonItem]];
        if (self.gridViewController.actionButtonItem) {
            [array addObject:self.gridViewController.actionButtonItem];
        }
    }
    else {
        if (UIInterfaceOrientationIsPortrait(orientation)) {
            [array addObject:[self popoverButtonItem]];
        }
        else {
            UIBarButtonItem *item = [[UIBarButtonItem alloc]
                                     initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                     target:self
                                     action:@selector(doneAction)];
            [array addObject:item];
            [item release];
        }
        [array addObject:[self flexibleSpaceButtonItem]];
        if (self.gridViewController.selectButtonItem) {
            [array addObject:self.gridViewController.selectButtonItem];
        }
    }
    self.toolbar.items = array;
}
- (void)updateToolbarItems {
    [self updateToolbarItemsForOrientation:self.interfaceOrientation];
}
- (void)cleanup {
    [self.popoverController dismissPopoverAnimated:NO];
    self.popoverController = nil;
    [self.gridViewController removeObserver:self forKeyPath:@"editing"];
    self.gridViewController = nil;
    self.listViewController = nil;
    self.leftView = nil;
    self.rightView = nil;
}
@end

@implementation GCImageBrowserController_iPad

@synthesize leftView=_leftView;
@synthesize rightView=_rightView;
@synthesize toolbar=_toolbar;
@synthesize titleLabel=_titleLabel;

@synthesize listViewController=_listViewController;
@synthesize gridViewController=_gridViewController;
@synthesize showAlbumList=_showAlbumList;
@synthesize popoverController=_popover;

#pragma mark - object lifecycle
- (id)init {
    self = [super initWithNibName:@"GCImageBrowserController_iPad" bundle:nil];
    if (self) {
        [self
         addObserver:self
         forKeyPath:@"title"
         options:NSKeyValueObservingOptionNew
         context:nil];
    }
    return self;
}
- (void)dealloc {
    [self cleanup];
    [self removeObserver:self forKeyPath:@"title"];
    [super dealloc];
}

#pragma mark - view lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
        
    // make list view
    GCImageListBrowserController *listView = [[GCImageListBrowserController alloc] init];
    listView.view.frame = self.leftView.bounds;
    listView.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    listView.selectedGroupBlock = ^(ALAssetsGroup *group) {
        
        // get group stuff
        NSString *groupID = [group valueForProperty:ALAssetsGroupPropertyPersistentID];
        ALAssetsGroupType groupType = [[group valueForProperty:ALAssetsGroupPropertyType] unsignedIntegerValue];
        NSString *groupName = [group valueForProperty:ALAssetsGroupPropertyName];
        self.title = groupName;
        
        // unload old view
        [self.gridViewController viewWillDisappear:NO];
        [self.gridViewController.view removeFromSuperview];
        [self.gridViewController viewDidDisappear:NO];
        [self.gridViewController removeObserver:self forKeyPath:@"editing"];
        
        // make new view
        GCImageGridBrowserController *gridView = [[GCImageGridBrowserController alloc]
                                                  initWithAssetsGroupTypes:groupType
                                                  title:groupName
                                                  groupID:groupID];
        [gridView
         addObserver:self
         forKeyPath:@"editing"
         options:NSKeyValueObservingOptionNew
         context:nil];
        gridView.actionBlock = self.actionBlock;
        gridView.actionEnabled = self.actionEnabled;
        gridView.actionTitle = self.actionTitle;
        gridView.view.frame = self.rightView.bounds;
        gridView.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        [gridView viewWillAppear:NO];
        [self.rightView addSubview:gridView.view];
        [gridView viewDidAppear:NO];
        self.gridViewController = gridView;
        [gridView release];
        
        // dsimiss popover
        [self.popoverController dismissPopoverAnimated:YES];
        self.popoverController = nil;

    };
    [self.leftView addSubview:listView.view];
    self.listViewController = listView;
    [listView release];
    
    // set asset group view
    NSArray *groups = self.listViewController.assetsGroups;
    if ([groups count]) {
        ALAssetsGroup *group = [self.listViewController.assetsGroups objectAtIndex:0];
        self.listViewController.selectedGroupBlock(group);
    }
    
    // portrait
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        self.navigationItem.leftBarButtonItem = [self popoverButtonItem];
    }
    
}
- (void)viewDidUnload {
    [super viewDidUnload];
    [self cleanup];
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration {
    [self view];
    [self.popoverController dismissPopoverAnimated:NO];
    self.popoverController = nil;
    [self updateToolbarItemsForOrientation:orientation];
    changeIsAnimated = (duration > 0);
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        if (duration > 0) { [self.listViewController viewWillDisappear:YES]; }
    }
    else {
        if (duration > 0) { [self.listViewController viewWillAppear:YES]; }
        self.listViewController.view.frame = self.leftView.bounds;
        [self.leftView addSubview:self.listViewController.view];
    }
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration {
    CGFloat originY = self.toolbar.bounds.size.height;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        self.leftView.frame = CGRectMake(0, originY, self.leftView.bounds.size.width, self.view.bounds.size.height - originY);
        self.rightView.frame = CGRectMake(320.0, originY, self.view.bounds.size.width - 320.0, self.view.bounds.size.height - originY);
    }
    else {
        self.leftView.frame = CGRectMake(-320.0, originY, self.leftView.bounds.size.width, self.view.bounds.size.height - originY);
        self.rightView.frame = CGRectMake(0, originY, self.view.bounds.size.width, self.view.bounds.size.height - originY);
    }
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)orientation {
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        [self.listViewController.view removeFromSuperview];
        if (changeIsAnimated) { [self.listViewController viewDidDisappear:YES]; }
    }
    else {
        if (changeIsAnimated) { [self.listViewController viewDidAppear:YES]; }
    }
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self.listViewController viewWillAppear:animated];
    [self.gridViewController viewWillAppear:animated];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.listViewController viewDidAppear:animated];
    [self.gridViewController viewDidAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.listViewController viewWillDisappear:animated];
    [self.gridViewController viewWillDisappear:animated];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.listViewController viewDidDisappear:animated];
    [self.gridViewController viewDidDisappear:animated];
}

#pragma mark - kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self && [keyPath isEqualToString:@"title"]) {
        id newValue = [change objectForKey:NSKeyValueChangeNewKey];
        if (newValue == [NSNull null]) { self.title = nil; }
        else { self.titleLabel.text = newValue; }
    }
    else if (object == self.gridViewController && [keyPath isEqualToString:@"editing"]) {
        [self updateToolbarItems];
        [self.popoverController dismissPopoverAnimated:YES];
        self.popoverController = nil;
    }
}

#pragma mark - button actions
- (void)doneAction {
    [self dismissModalViewControllerAnimated:YES];
}
- (void)popoverAction:(UIBarButtonItem *)sender {
    if (!self.popoverController) {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self.listViewController];
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:nav];
        [popover setDelegate:self];
        [popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        self.popoverController = popover;
        [popover release];
        [nav release];
    }
}

#pragma mark - popover delegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popover {
    if (popover == self.popoverController) {
        self.popoverController = nil;
    }
}

@end

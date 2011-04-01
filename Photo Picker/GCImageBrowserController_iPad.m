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
- (UIBarButtonItem *)popoverButton;
- (void)cleanup;
@end

@implementation GCImageBrowserController_iPad (private)
- (UIBarButtonItem *)popoverButton {
    UIBarButtonItem *item = [[UIBarButtonItem alloc]
                             initWithTitle:self.listViewController.title
                             style:UIBarButtonItemStylePlain
                             target:self
                             action:@selector(popoverAction:)];
    return [item autorelease];
}
- (void)cleanup {
//    [self.gridViewController removeObserver:self forKeyPath:@"title"];
    self.gridViewController = nil;
    self.listViewController = nil;
    [self.popoverController dismissPopoverAnimated:NO];
    self.popoverController = nil;
    self.leftView = nil;
    self.rightView = nil;
}
@end

@implementation GCImageBrowserController_iPad

@synthesize leftView=_leftView;
@synthesize rightView=_rightView;
@synthesize listViewController=_listViewController;
@synthesize gridViewController=_gridViewController;
@synthesize showAlbumList=_showAlbumList;
@synthesize popoverController=_popover;

#pragma mark - object lifecycle
- (id)init {
    self = [super initWithNibName:@"GCImageBrowserController_iPad" bundle:nil];
    return self;
}
- (void)dealloc {
    [self cleanup];
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
        
        // unload old view
        [self.gridViewController viewWillDisappear:NO];
        [self.gridViewController.view removeFromSuperview];
        [self.gridViewController viewDidDisappear:NO];
        
        // make new view
        GCImageGridBrowserController *gridView = [[GCImageGridBrowserController alloc]
                                                  initWithAssetsGroupTypes:groupType
                                                  title:groupName
                                                  groupID:groupID];
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

    };
    [self.leftView addSubview:listView.view];
    self.listViewController = listView;
    [listView release];
    
    // make grid view
    GCImageGridBrowserController *gridView = [[GCImageGridBrowserController alloc]
                                              initWithAssetsGroupTypes:ALAssetsGroupAll
                                              title:@"ASDF"
                                              groupID:nil];
    gridView.actionBlock = self.actionBlock;
    gridView.actionEnabled = self.actionEnabled;
    gridView.actionTitle = self.actionTitle;
    gridView.view.frame = self.rightView.bounds;
    gridView.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [self.rightView addSubview:gridView.view];
    self.gridViewController = gridView;
    [gridView release];
    
    // portrait
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        self.navigationItem.leftBarButtonItem = [self popoverButton];
    }
    
}
- (void)viewDidUnload {
    [super viewDidUnload];
    [self cleanup];
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration {
    [self.popoverController dismissPopoverAnimated:NO];
    self.popoverController = nil;
    changeIsAnimated = (duration > 0);
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        if (duration > 0) { [self.listViewController viewWillDisappear:YES]; }
        self.navigationItem.leftBarButtonItem = [self popoverButton];
    }
    else {
        if (duration > 0) { [self.listViewController viewWillAppear:YES]; }
        self.navigationItem.leftBarButtonItem = nil;
        self.listViewController.view.frame = self.leftView.bounds;
        [self.leftView addSubview:self.listViewController.view];
    }
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration {
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        self.leftView.frame = CGRectMake(0, 0, self.leftView.bounds.size.width, self.view.bounds.size.height);
        self.rightView.frame = CGRectMake(320.0, 0, self.view.bounds.size.width - 320.0, self.view.bounds.size.height);
    }
    else {
        self.leftView.frame = CGRectMake(-320.0, 0, self.leftView.bounds.size.width, self.view.bounds.size.height);
        self.rightView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
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
    if (object == self.gridViewController && [keyPath isEqualToString:@"title"]) {
        id newValue = [change objectForKey:NSKeyValueChangeNewKey];
        if (newValue == [NSNull null]) { self.title = nil; }
        else { self.title = newValue; }
    }
}

#pragma mark - button actions
- (void)popoverAction:(UIBarButtonItem *)sender {
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self.listViewController];
    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:nav];
    [popover setDelegate:self];
    [popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    self.popoverController = popover;
    [popover release];
    [nav release];
}

#pragma mark - popover delegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popover {
    if (popover == self.popoverController) {
        self.popoverController = nil;
    }
}

@end

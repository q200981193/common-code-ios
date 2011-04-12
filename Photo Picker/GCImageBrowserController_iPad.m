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

#define kGreyOutViewTag 100

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
        if (self.gridViewController.actionButtonItem) {
            [array addObject:self.gridViewController.actionButtonItem];
        }
        [array addObject:[self flexibleSpaceButtonItem]];
        if (self.gridViewController.cancelButtonItem) {
            [array addObject:self.gridViewController.cancelButtonItem];
        }
    }
    else {
        UIBarButtonItem *item = [[UIBarButtonItem alloc]
                                 initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                 target:self
                                 action:@selector(doneAction)];
        [array addObject:item];
        [item release];
        if (UIInterfaceOrientationIsPortrait(orientation)) {
            [array addObject:[self popoverButtonItem]];
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
    [self.gridViewController removeObserver:self forKeyPath:@"title"];
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

@synthesize gridViewController=_gridViewController;
@synthesize listViewController=_listViewController;
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
    
    // blocks
    __block GCImageBrowserController_iPad *browser = self;
    void (^gridLoadBlock) (ALAssetsGroup *group, BOOL callViewMethods) = ^(ALAssetsGroup *group, BOOL callViewMethods) {
        
        // dsimiss popover
        [browser.popoverController dismissPopoverAnimated:YES];
        browser.popoverController = nil;
        
        // get group stuff
        NSString *groupID = [group valueForProperty:ALAssetsGroupPropertyPersistentID];
        ALAssetsGroupType groupType = [[group valueForProperty:ALAssetsGroupPropertyType] unsignedIntegerValue];
        NSString *groupName = [group valueForProperty:ALAssetsGroupPropertyName];
        browser.title = groupName;
        
        // unload old view
        if (callViewMethods) { [browser.gridViewController viewWillDisappear:NO]; }
        [browser.gridViewController.view removeFromSuperview];
        if (callViewMethods) { [browser.gridViewController viewDidDisappear:NO]; }
        [browser.gridViewController removeObserver:self forKeyPath:@"editing"];
        [browser.gridViewController removeObserver:self forKeyPath:@"title"];
        
        // make new view
        GCImageGridBrowserController *gridView = [[GCImageGridBrowserController alloc] initWithAssetsGroupTypes:groupType title:groupName groupID:groupID];
        [gridView addObserver:self forKeyPath:@"editing" options:NSKeyValueObservingOptionNew context:nil];
        [gridView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
        gridView.actionBlock = self.actionBlock;
        gridView.actionEnabled = self.actionEnabled;
        gridView.actionTitle = self.actionTitle;
        //gridView.mediaTypes = self.mediaTypes;
        gridView.view.frame = self.rightView.bounds;
        gridView.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        if (callViewMethods) { [browser.gridViewController viewWillAppear:NO]; }
        [self.rightView addSubview:gridView.view];
        if (callViewMethods) { [browser.gridViewController viewDidAppear:NO]; }
        self.gridViewController = gridView;
        [gridView release];
        
        // buttons
        [self updateToolbarItems];
        
    };
    GCImageListBrowserSelectedGroupBlock selectedBlock = ^(ALAssetsGroup *group) {
        gridLoadBlock(group, YES);
    };
        
    // make list view
    GCImageListBrowserController *listView = [[GCImageListBrowserController alloc] init];
    listView.selectedGroupBlock = selectedBlock;
    listView.mediaTypes = self.mediaTypes;
    listView.view.frame = self.leftView.bounds;
    listView.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    [self.leftView addSubview:listView.view];
    self.listViewController = listView;
    [listView release];
    
    // set asset group view
    NSArray *groups = self.listViewController.assetsGroups;
    if ([groups count]) {
        ALAssetsGroup *group = [self.listViewController.assetsGroups objectAtIndex:0];
        gridLoadBlock(group, NO);
    }
    
}
- (void)viewDidUnload {
    [super viewDidUnload];
    [self cleanup];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self.listViewController viewWillAppear:animated];
    [self.gridViewController viewWillAppear:animated];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.toolbar setNeedsLayout];
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

#pragma mark - view roration
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return YES;
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration {
    
    // forward calls
    [self.listViewController willRotateToInterfaceOrientation:orientation duration:duration];
    [self.gridViewController willRotateToInterfaceOrientation:orientation duration:duration];
    
    // update toolbar
    if ([self isViewLoaded]) { [self updateToolbarItemsForOrientation:orientation]; }
    
    // check if rotation is animated
    isRotationAnimated = (duration > 0);
    
    // make sure we aren't rotating to a similar orientation
    if (UIInterfaceOrientationIsPortrait(orientation) == UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        return;
    }
    
    // do stuff depending on the new orientation
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        [self.listViewController viewWillDisappear:isRotationAnimated];
    }
    else {
        [self.popoverController dismissPopoverAnimated:NO];
        self.popoverController = nil;
        [self.listViewController viewWillAppear:isRotationAnimated];
        self.listViewController.view.frame = self.leftView.bounds;
        [self.leftView addSubview:self.listViewController.view];
        [self.leftView sendSubviewToBack:self.listViewController.view];
    }
        
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)orientation {
    
    // forward calls
    [self.listViewController didRotateFromInterfaceOrientation:orientation];
    [self.gridViewController didRotateFromInterfaceOrientation:orientation];
    
    // make sure we aren't rotating to a similar orientation
    if (UIInterfaceOrientationIsPortrait(orientation) == UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        return;
    }
    
    // do stuff depending on the new orientation
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        [self.listViewController viewDidDisappear:isRotationAnimated];
    }
    else {
        [self.listViewController viewDidAppear:isRotationAnimated];
    }
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration {
    
    // forward calls
    [self.listViewController willAnimateRotationToInterfaceOrientation:orientation duration:duration];
    [self.gridViewController willAnimateRotationToInterfaceOrientation:orientation duration:duration];
    
    // set new view positions
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
- (void)willAnimateFirstHalfOfRotationToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration {
    [self.listViewController willAnimateFirstHalfOfRotationToInterfaceOrientation:orientation duration:duration];
    [self.gridViewController willAnimateFirstHalfOfRotationToInterfaceOrientation:orientation duration:duration];
}
- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration {
    [self.listViewController willAnimateSecondHalfOfRotationFromInterfaceOrientation:orientation duration:duration];
    [self.gridViewController willAnimateSecondHalfOfRotationFromInterfaceOrientation:orientation duration:duration];
}

#pragma mark - kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self && [keyPath isEqualToString:@"title"]) {
        id newValue = [change objectForKey:NSKeyValueChangeNewKey];
        if (newValue == [NSNull null]) { self.titleLabel.text = nil; }
        else { self.titleLabel.text = newValue; }
    }
    else if (object == self.gridViewController && [keyPath isEqualToString:@"editing"]) {
        [self updateToolbarItems];
        [self.popoverController dismissPopoverAnimated:YES];
        self.popoverController = nil;
        id newValue = [change objectForKey:NSKeyValueChangeNewKey];
        BOOL editing = [newValue boolValue];
        if (editing) {
            UIView *greyOut = [[UIView alloc] initWithFrame:self.leftView.bounds];
            greyOut.backgroundColor = [UIColor blackColor];
            greyOut.alpha = 0.0;
            greyOut.tag = kGreyOutViewTag;
            [self.leftView addSubview:greyOut];
            [UIView
             animateWithDuration:0.3
             animations:^{
                 greyOut.alpha = 0.5;
             }];
            [greyOut release];
        }
        else {
            UIView *greyOut = [self.leftView viewWithTag:kGreyOutViewTag];
            [UIView
             animateWithDuration:0.3
             animations:^{
                 greyOut.alpha = 0.0;
             }
             completion:^(BOOL finished){
                 [greyOut removeFromSuperview];
             }];
        }
    }
    else if (object == self.gridViewController && [keyPath isEqualToString:@"title"]) {
        id newValue = [change objectForKey:NSKeyValueChangeNewKey];
        if (newValue == [NSNull null]) { self.title = nil; }
        else { self.title = newValue; }
    }
}

#pragma mark - button actions
- (void)doneAction {
    [self dismissModalViewControllerAnimated:YES];
}
- (void)popoverAction:(UIBarButtonItem *)sender {
    if (!self.popoverController) {
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:self.listViewController];
        [popover setDelegate:self];
        [popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        self.popoverController = popover;
        [popover release];
    }
}

#pragma mark - popover delegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popover {
    if (popover == self.popoverController) {
        self.popoverController = nil;
    }
}

@end

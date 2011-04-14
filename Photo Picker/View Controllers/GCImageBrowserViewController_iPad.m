//
//  GCImageBrowserController_iPad.m
//  GUI Cocoa Common Code Library for iOS
//
//  Created by Caleb Davenport on 3/31/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

#import "GCImageBrowserViewController.h"
#import "GCImageBrowserViewController_iPad.h"

#define kGreyOutViewTag 100

@interface GCImageBrowserViewController_iPad (private)

// update toolbar items
- (void)updateToolbarItemsForOrientation:(UIInterfaceOrientation)orientation;
- (void)updateToolbarItems;

// update view layout
- (void)updateViewLayoutForOrientation:(UIInterfaceOrientation)orientation;
- (void)updateViewLayout;

// release resources
- (void)cleanup;

// get standard button items
- (UIBarButtonItem *)popoverButtonItem;
- (UIBarButtonItem *)flexibleSpaceButtonItem;

@end

@implementation GCImageBrowserViewController_iPad (private)
- (void)updateToolbarItemsForOrientation:(UIInterfaceOrientation)orientation {
    NSMutableArray *array = [NSMutableArray array];
//    if (self.gridViewController.editing) {
//        if (self.gridViewController.actionButtonItem) {
//            [array addObject:self.gridViewController.actionButtonItem];
//        }
//        [array addObject:[self flexibleSpaceButtonItem]];
//        if (self.gridViewController.cancelButtonItem) {
//            [array addObject:self.gridViewController.cancelButtonItem];
//        }
//    }
    if (self.gridController.editing) {
        [array addObject:[self flexibleSpaceButtonItem]];
    }
    else {
        
        // done button
        {
            UIBarButtonItem *item = [[UIBarButtonItem alloc]
                                     initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                     target:self
                                     action:@selector(doneAction)];
            [array addObject:item];
            [item release];
        }
        
        // popover button
        if (UIInterfaceOrientationIsPortrait(orientation)) {
            UIBarButtonItem *item = [[UIBarButtonItem alloc]
                                     initWithTitle:self.listController.title
                                     style:UIBarButtonItemStyleBordered
                                     target:self
                                     action:@selector(popoverAction:)];
            [array addObject:item];
            [item release];
        }
        
        // space
        [array addObject:[self flexibleSpaceButtonItem]];
        
    }
    self.toolbar.items = array;
}
- (void)updateToolbarItems {
    [self updateToolbarItemsForOrientation:self.interfaceOrientation];
}
- (void)updateViewLayoutForOrientation:(UIInterfaceOrientation)orientation {
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
- (void)updateViewLayout {
    [self updateViewLayoutForOrientation:self.interfaceOrientation];
}
- (void)cleanup {
    [self.popover dismissPopoverAnimated:NO];
    self.popover = nil;
    [self.gridController removeObserver:self forKeyPath:@"editing"];
    [self.gridController removeObserver:self forKeyPath:@"title"];
    self.gridController = nil;
    self.listController = nil;
    self.leftView = nil;
    self.rightView = nil;
}
- (UIBarButtonItem *)popoverButtonItem {
    return [[[UIBarButtonItem alloc]
             initWithTitle:self.listController.title
             style:UIBarButtonItemStyleBordered
             target:self
             action:@selector(popoverAction:)]
            autorelease];
}
- (UIBarButtonItem *)flexibleSpaceButtonItem {
    return [[[UIBarButtonItem alloc]
             initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
             target:nil
             action:nil]
            autorelease];
}
@end

@implementation GCImageBrowserViewController_iPad

@synthesize dataSource=_dataSource;

@synthesize leftView=_leftView;
@synthesize rightView=_rightView;
@synthesize toolbar=_toolbar;
@synthesize titleLabel=_titleLabel;

@synthesize gridController=_gridViewController;
@synthesize listController=_listViewController;
@synthesize popover=_popover;

#pragma mark - object lifecycle
- (id)init {
    self = [super initWithNibName:@"GCImageBrowserViewController_iPad" bundle:nil];
    if (self) {
        [self
         addObserver:self
         forKeyPath:@"title"
         options:0
         context:nil];
    }
    return self;
}
- (void)dealloc {
    [self removeObserver:self forKeyPath:@"title"];
    [self cleanup];
    [super dealloc];
}

#pragma mark - view lifecycle
- (void)viewDidLoad {
    
    // super
    [super viewDidLoad];
        
    // make list view
    GCImageListBrowserController *browser = [[GCImageListBrowserController alloc] init];
    browser.view.frame = self.leftView.bounds;
    browser.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    browser.dataSource = self.dataSource;
    browser.delegate = self;
    browser.showDisclosureIndicator = NO;
    [browser reloadData];
    [self.leftView addSubview:browser.view];
    self.listController = browser;
    [browser release];
    
    // set asset group view
    NSArray *groups = self.listController.assetsGroups;
    if ([groups count]) {
        ALAssetsGroup *group = [self.listController.assetsGroups objectAtIndex:0];
        [self listBrowser:self.listController didSelectAssetGroup:group];
    }
    
}
- (void)viewDidUnload {
    [super viewDidUnload];
    [self cleanup];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self updateViewLayout];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.toolbar setNeedsLayout];
    [self.gridController.tableView flashScrollIndicators];
    [self.listController.tableView flashScrollIndicators];
}

#pragma mark - list browser delegate
- (void)listBrowser:(GCImageListBrowserController *)controller didSelectAssetGroup:(ALAssetsGroup *)group {
    
    // dsimiss popover
    [self.popover dismissPopoverAnimated:YES];
    self.popover = nil;
    
    // get group stuff
    NSString *groupID = [group valueForProperty:ALAssetsGroupPropertyPersistentID];
    
    // unload old view
    [self.gridController.view removeFromSuperview];
    [self.gridController removeObserver:self forKeyPath:@"editing"];
    [self.gridController removeObserver:self forKeyPath:@"title"];
    
    // make new view
    GCImageGridBrowserController *browser = [[GCImageGridBrowserController alloc] initWithAssetsGroupIdentifier:groupID];
    browser.view.frame = self.rightView.bounds;
    browser.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    browser.dataSource = self.dataSource;
    browser.numberOfAssetsPerRow = 6;
    browser.assetViewPadding = 10.0;
    browser.tableView.contentInset = UIEdgeInsetsMake(browser.assetViewPadding, 0, 0, 0);
    self.gridController = browser;
    [browser addObserver:self forKeyPath:@"editing" options:NSKeyValueObservingOptionNew context:nil];
    [browser addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    [browser reloadData];
    [self.rightView addSubview:browser.view];
    [browser release];
    
    // update interface
    [self updateToolbarItems];
    [self updateViewLayout];
    NSIndexPath *indexPath = [controller.tableView indexPathForSelectedRow];
    [controller.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - view roration
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return YES;
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration {
    
    // update toolbar
    if ([self isViewLoaded]) { [self updateToolbarItemsForOrientation:orientation]; }
    
    // make sure we aren't rotating to a similar orientation
    if (UIInterfaceOrientationIsPortrait(orientation) == UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        return;
    }
    
    // do stuff depending on the new orientation
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        [self.popover dismissPopoverAnimated:NO];
        self.popover = nil;
        self.listController.view.frame = self.leftView.bounds;
        [self.leftView addSubview:self.listController.view];
        [self.leftView sendSubviewToBack:self.listController.view];
    }
        
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration {
    [self updateViewLayoutForOrientation:orientation];
}

#pragma mark - kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self && [keyPath isEqualToString:@"title"]) {
        self.titleLabel.text = self.title;
    }
    else if (object == self.gridController && [keyPath isEqualToString:@"editing"]) {
        [self updateToolbarItems];
        [self.popover dismissPopoverAnimated:YES];
        self.popover = nil;
        if (self.gridController.editing) {
            UIView *greyOut = [[UIView alloc] initWithFrame:self.leftView.bounds];
            greyOut.backgroundColor = [UIColor blackColor];
            greyOut.alpha = 0.0;
            greyOut.tag = kGreyOutViewTag;
            greyOut.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
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
    else if (object == self.gridController && [keyPath isEqualToString:@"title"]) {
        self.title = self.gridController.title;
    }
}

#pragma mark - button actions
- (void)doneAction {
    [self dismissModalViewControllerAnimated:YES];
}
- (void)popoverAction:(UIBarButtonItem *)sender {
    if (!self.popover) {
        GCImageBrowserViewController *controller = [[GCImageBrowserViewController alloc] init];
        controller.browser = self.listController;
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:controller];
        self.popover = popover;
        popover.delegate = self;
        [popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        [popover release];
        [controller release];
    }
}

#pragma mark - popover delegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popover {
    if (popover == self.popover) {
        self.popover = nil;
    }
}

@end

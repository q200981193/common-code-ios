/*
 
 Copyright (C) 2011 GUI Cocoa, LLC.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */

#import "GCAssetBrowserViewController_iPad.h"
#import "GCImagePickerController.h"
#import "GCAssetGridBrowser.h"

#define kGreyOutViewTag 100

@interface GCAssetBrowserViewController_iPad (private)

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

@implementation GCAssetBrowserViewController_iPad (private)
- (void)updateToolbarItemsForOrientation:(UIInterfaceOrientation)orientation {
    if (_gridBrowser.editing) {
        self.navigationItem.leftBarButtonItem = _gridBrowser.cancelButtonItem;
        self.navigationItem.rightBarButtonItem = _gridBrowser.actionButtonItem;
    }
    else {
        if (UIInterfaceOrientationIsPortrait(orientation)) {
            UIBarButtonItem *item = [[UIBarButtonItem alloc]
                                     initWithTitle:_listBrowser.title
                                     style:UIBarButtonItemStyleBordered
                                     target:self
                                     action:@selector(popoverAction:)];
            self.navigationItem.leftBarButtonItem = item;
            [item release];
        }
        else {
            self.navigationItem.leftBarButtonItem = nil;
        }
        UIBarButtonItem *item = [[UIBarButtonItem alloc]
                                 initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                 target:self
                                 action:@selector(doneAction)];
        self.navigationItem.rightBarButtonItem = item;
        [item release];
    }
}
- (void)updateToolbarItems {
    [self updateToolbarItemsForOrientation:self.interfaceOrientation];
}
- (void)updateViewLayoutForOrientation:(UIInterfaceOrientation)orientation {
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        self.leftView.frame = CGRectMake(0, 0, self.leftView.bounds.size.width, self.view.bounds.size.height);
        self.rightView.frame = CGRectMake(320.0, 0, self.view.bounds.size.width - 320.0, self.view.bounds.size.height);
    }
    else {
        self.leftView.frame = CGRectMake(-320.0, 0, self.leftView.bounds.size.width, self.view.bounds.size.height);
        self.rightView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    }
}
- (void)updateViewLayout {
    [self updateViewLayoutForOrientation:self.interfaceOrientation];
}
- (void)cleanup {
    [popoverController dismissPopoverAnimated:NO];
    [popoverController release];
    popoverController = nil;
    [_gridBrowser removeObserver:self forKeyPath:@"editing"];
    [_gridBrowser removeObserver:self forKeyPath:@"title"];
    [_gridBrowser release];
    _gridBrowser = nil;
    [_listBrowser release];
    _listBrowser = nil;
    self.leftView = nil;
    self.rightView = nil;
}
- (UIBarButtonItem *)popoverButtonItem {
    return [[[UIBarButtonItem alloc]
             initWithTitle:_listBrowser.title
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

@implementation GCAssetBrowserViewController_iPad

@synthesize picker=_picker;
@synthesize leftView;
@synthesize rightView;

#pragma mark - object methods
- (id)initWithImagePickerController:(GCImagePickerController *)picker {
    self = [super initWithNibName:@"GCImageBrowserViewController_iPad" bundle:nil];
    if (self) {
        _picker = [picker retain];
    }
    return self;
}
- (void)dealloc {
    [self cleanup];
    [super dealloc];
}
- (void)reloadData {
    [super reloadData];
    if ([self isViewLoaded]) {
        [_listBrowser reloadData];
        [_gridBrowser reloadData];
    }
}

#pragma mark - view lifecycle
- (void)viewDidLoad {
    
    // super
    [super viewDidLoad];
    
    // list view
    _listBrowser = [[GCAssetListBrowser alloc] initWithImagePickerController:self.picker];
    _listBrowser.view.frame = self.leftView.bounds;
    _listBrowser.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    _listBrowser.listBrowserDelegate = self;
    _listBrowser.showDisclosureIndicators = NO;
    [_listBrowser reloadData];
    [self.leftView addSubview:_listBrowser.view];
    
    // set asset group view
    NSArray *groups = _listBrowser.groups;
    if ([groups count]) {
        ALAssetsGroup *group = [groups objectAtIndex:0];
        [self listBrowser:_listBrowser didSelectAssetGroup:group];
    }
    else {
        self.leftView.hidden = YES;
        self.rightView.hidden = YES;
        self.view.backgroundColor = [UIColor whiteColor];
        UIBarButtonItem *item = [[UIBarButtonItem alloc]
                                 initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                 target:self
                                 action:@selector(doneAction)];
        self.navigationItem.rightBarButtonItem = item;
        [item release];
        self.title = GCImagePickerControllerLocalizedString(@"PHOTO_LIBRARY");
    }
    
}
- (void)viewDidUnload {
    [super viewDidUnload];
    [self cleanup];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateViewLayout];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_gridBrowser.tableView flashScrollIndicators];
    [_listBrowser.tableView flashScrollIndicators];
}

#pragma mark - list browser delegate
- (void)listBrowser:(GCAssetListBrowser *)browser didSelectAssetGroup:(ALAssetsGroup *)group {
    
    // dsimiss popover
    [popoverController dismissPopoverAnimated:YES];
    [popoverController release];
    popoverController = nil;
    
    // get group stuff
    NSString *groupIdentifier = [group valueForProperty:ALAssetsGroupPropertyPersistentID];
    
    // unload old view
    [_gridBrowser.view removeFromSuperview];
    [_gridBrowser removeObserver:self forKeyPath:@"editing"];
    [_gridBrowser removeObserver:self forKeyPath:@"title"];
    [_gridBrowser release];
    
    // make new view
    _gridBrowser = [[GCAssetGridBrowser alloc] initWithImagePickerController:browser.picker groupIdentifier:groupIdentifier];
    [_gridBrowser addObserver:self forKeyPath:@"editing" options:0 context:0];
    [_gridBrowser addObserver:self forKeyPath:@"title" options:0 context:0];
    _gridBrowser.view.frame = self.rightView.bounds;
    _gridBrowser.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    _gridBrowser.numberOfAssetsPerRow = 6;
    _gridBrowser.assetViewPadding = 10.0;
    [_gridBrowser reloadData];
    [self.rightView addSubview:_gridBrowser.view];
    
    // update interface
    [self updateToolbarItems];
    [self updateViewLayout];
    NSIndexPath *indexPath = [browser.tableView indexPathForSelectedRow];
    [browser.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - view roration
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    GC_SHOULD_ALLOW_ORIENTATION(orientation);
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
        [popoverController dismissPopoverAnimated:NO];
        [popoverController release];
        popoverController = nil;
        _listBrowser.view.frame = self.leftView.bounds;
        [self.leftView addSubview:_listBrowser.view];
        [self.leftView sendSubviewToBack:_listBrowser.view];
    }
        
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration {
    [self updateViewLayoutForOrientation:orientation];
}

#pragma mark - kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    // super
    if ([super respondsToSelector:_cmd]) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
    // self
    if (object == _gridBrowser && [keyPath isEqualToString:@"editing"]) {
        [self updateToolbarItems];
        [popoverController dismissPopoverAnimated:YES];
        [popoverController release];
        popoverController = nil;
        if (_gridBrowser.editing) {
            UIView *greyOut = [[UIView alloc] initWithFrame:self.leftView.bounds];
            greyOut.backgroundColor = [UIColor blackColor];
            greyOut.alpha = 0.0;
            greyOut.tag = kGreyOutViewTag;
            greyOut.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
            [self.leftView addSubview:greyOut];
            [UIView
             animateWithDuration:0.2
             animations:^{
                 greyOut.alpha = 0.5;
             }];
            [greyOut release];
        }
        else {
            UIView *greyOut = [self.leftView viewWithTag:kGreyOutViewTag];
            [UIView
             animateWithDuration:0.2
             animations:^{
                 greyOut.alpha = 0.0;
             }
             completion:^(BOOL finished){
                 [greyOut removeFromSuperview];
             }];
        }
    }
    else if (object == _gridBrowser && [keyPath isEqualToString:@"title"]) {
        self.title = _gridBrowser.title;
    }
    else if (object == _gridBrowser && [keyPath isEqualToString:@"actionButtonItem"]) {
        [self updateToolbarItems];
    }
}

#pragma mark - button actions
- (void)doneAction {
    [self dismissModalViewControllerAnimated:YES];
}
- (void)popoverAction:(UIBarButtonItem *)sender {
    if (popoverController == nil) {
        GCAssetBrowserViewController *controller = [[GCAssetBrowserViewController alloc] initWithBrowser:_listBrowser];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
        popoverController = [[UIPopoverController alloc] initWithContentViewController:navController];
        popoverController.delegate = self;
        [popoverController
         presentPopoverFromBarButtonItem:sender
         permittedArrowDirections:UIPopoverArrowDirectionAny
         animated:YES];
        [controller release];
        [navController release];
    }
}

#pragma mark - popover delegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popover {
    if (popover == popoverController) {
        [popoverController release];
        popoverController = nil;
    }
}

@end

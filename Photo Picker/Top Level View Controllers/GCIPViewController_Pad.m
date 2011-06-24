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

#import <AssetsLibrary/AssetsLibrary.h>

#import "GCIPViewController_Pad.h"

@interface GCIPViewController_Pad (private)
- (void)layoutViews;
- (void)layoutViewsForOrientation:(UIInterfaceOrientation)orientation;
- (UIBarButtonItem *)popoverBarButtonItem;
- (UIBarButtonItem *)doneBarButtonItem;
@end

@implementation GCIPViewController_Pad (private)
- (void)layoutViews {
    [self layoutViewsForOrientation:self.interfaceOrientation];
}
- (void)layoutViewsForOrientation:(UIInterfaceOrientation)orientation {
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        masterViewController.view.frame = CGRectMake(-320.0, 0, 320.0, self.view.bounds.size.height);
        detailViewController.view.frame = self.view.bounds;
    }
    else {
        masterViewController.view.frame = CGRectMake(0, 0, 320.0, self.view.bounds.size.height);
        detailViewController.view.frame = CGRectMake(321.0, 0.0, self.view.bounds.size.width - 321.0,
                                                     self.view.bounds.size.height);
    }
}
- (UIBarButtonItem *)popoverBarButtonItem {
    UIBarButtonItem *item = [[UIBarButtonItem alloc]
                             initWithTitle:masterViewController.title
                             style:UIBarButtonItemStyleBordered 
                             target:self
                             action:@selector(popover:)];
    return [item autorelease];
}
- (UIBarButtonItem *)doneBarButtonItem {
    UIBarButtonItem *item = [[UIBarButtonItem alloc]
                             initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                             target:self
                             action:@selector(done)];
    return [item autorelease];
}
@end

@implementation GCIPViewController_Pad

@synthesize actionBlock=_actionBlock;
@synthesize actionTitle=_actionTitle;
@synthesize actionEnabled=_actionEnabled;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        // create group picker controller
        groupPicker = [[GCIPGroupPickerController alloc] initWithNibName:nil bundle:nil];
        groupPicker.pickerDelegate = self;
        groupPicker.showDisclosureIndicators = NO;
        masterViewController = [[UINavigationController alloc] initWithRootViewController:groupPicker];
        [masterViewController setValue:self forKey:@"parentViewController"];
        
        // asset picker
        assetPicker = [[GCIPAssetPickerController alloc] initWithNibName:nil bundle:nil];
        [assetPicker
         addObserver:self
         forKeyPath:@"navigationItem.leftBarButtonItem"
         options:0
         context:0];
        [assetPicker
         addObserver:self
         forKeyPath:@"navigationItem.rightBarButtonItem"
         options:0
         context:0];
        detailViewController = [[UINavigationController alloc] initWithRootViewController:assetPicker];
        [detailViewController setValue:self forKey:@"parentViewController"];
        
    }
    return self;
}
- (void)dealloc {
    [masterViewController release];
    masterViewController = nil;
    [groupPicker release];
    groupPicker = nil;
    [detailViewController release];
    detailViewController = nil;
    [assetPicker
     removeObserver:self
     forKeyPath:@"navigationItem.rightBarButtonItem"];
    [assetPicker
     removeObserver:self
     forKeyPath:@"navigationItem.leftBarButtonItem"];
    [assetPicker release];
    assetPicker = nil;
    [library release];
    library = nil;
    [popover dismissPopoverAnimated:NO];
    [self popoverControllerDidDismissPopover:popover];
    [super dealloc];
}

#pragma mark - accessors
- (ALAssetsLibrary *)assetsLibrary {
    if (library == nil) {
        library = [[ALAssetsLibrary alloc] init];
    }
    return library;
}

#pragma mark - view lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    masterViewController.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    detailViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:masterViewController.view];
    [self.view addSubview:detailViewController.view];
    [self layoutViews];
    self.view.backgroundColor = [UIColor blackColor];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [masterViewController viewWillAppear:animated];
    [detailViewController viewWillAppear:animated];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [masterViewController viewDidAppear:animated];
    [detailViewController viewDidAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [masterViewController viewWillDisappear:animated];
    [detailViewController viewWillDisappear:animated];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [masterViewController viewDidDisappear:animated];
    [detailViewController viewDidDisappear:animated];
}

#pragma mark - view rotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    GC_SHOULD_ALLOW_ORIENTATION(orientation);
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration {
    [masterViewController willRotateToInterfaceOrientation:orientation duration:duration];
    [detailViewController willRotateToInterfaceOrientation:orientation duration:duration];
    if (UIInterfaceOrientationIsPortrait(orientation) == UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        return;
    }
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        [popover dismissPopoverAnimated:NO];
        [self popoverControllerDidDismissPopover:popover];
        [self.view addSubview:masterViewController.view];
    }
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration {
    [masterViewController willAnimateRotationToInterfaceOrientation:orientation duration:duration];
    [detailViewController willAnimateRotationToInterfaceOrientation:orientation duration:duration];
    [self layoutViewsForOrientation:orientation];
}
- (void)willAnimateFirstHalfOfRotationToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration {
    [masterViewController willAnimateFirstHalfOfRotationToInterfaceOrientation:orientation duration:duration];
    [detailViewController willAnimateFirstHalfOfRotationToInterfaceOrientation:orientation duration:duration];
}
- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration {
    [masterViewController willAnimateSecondHalfOfRotationFromInterfaceOrientation:orientation duration:duration];
    [detailViewController willAnimateSecondHalfOfRotationFromInterfaceOrientation:orientation duration:duration];
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)orientation {
    [masterViewController didRotateFromInterfaceOrientation:orientation];
    [detailViewController didRotateFromInterfaceOrientation:orientation];
    if (UIInterfaceOrientationIsPortrait(orientation) == UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        return;
    }
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        if (assetPicker.navigationItem.leftBarButtonItem == nil) {
            popoverButton = assetPicker.navigationItem.leftBarButtonItem = [self popoverBarButtonItem];
        }
    }
    else {
        if (assetPicker.navigationItem.leftBarButtonItem == popoverButton) {
            popoverButton = assetPicker.navigationItem.leftBarButtonItem = nil;
        }
    }
}

#pragma mark - button actions
- (void)popover:(UIBarButtonItem *)sender {
    if (popover == nil) {
        popover = [[UIPopoverController alloc] initWithContentViewController:masterViewController];
        popover.delegate = self;
        [popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}
- (void)done {
    [popover dismissPopoverAnimated:NO];
    [self popoverControllerDidDismissPopover:popover];
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - group picker delegate
- (void)groupPicker:(GCIPGroupPickerController *)picker didPickGroup:(ALAssetsGroup *)group {
    
    // setup asset view
    NSString *identifier = [group valueForProperty:ALAssetsGroupPropertyPersistentID];
    assetPicker.groupIdentifier = identifier;
    [assetPicker.tableView scrollRectToVisible:CGRectZero animated:NO];
    [assetPicker.tableView flashScrollIndicators];
    
    // setup group view
    NSIndexPath *indexPath = [picker.tableView indexPathForSelectedRow];
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        [picker.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else {
        [popover dismissPopoverAnimated:YES];
        [self popoverControllerDidDismissPopover:popover];
        [picker.tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
   
}

#pragma mark - kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == assetPicker && [keyPath isEqualToString:@"navigationItem.leftBarButtonItem"]) {
        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation) && assetPicker.navigationItem.leftBarButtonItem == nil) {
            popoverButton = assetPicker.navigationItem.leftBarButtonItem = [self popoverBarButtonItem];
        }
    }
    if (object == assetPicker && [keyPath isEqualToString:@"navigationItem.rightBarButtonItem"]) {
        if (assetPicker.navigationItem.rightBarButtonItem == nil) {
            UIBarButtonItem *item = [[UIBarButtonItem alloc]
                                     initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                     target:self
                                     action:@selector(done)];
            assetPicker.navigationItem.rightBarButtonItem = item;
            [item release];
        }
    }
}

#pragma mark - popover delegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    if (popoverController == popover) {
        [popover release];
        popover = nil;
    }
}

@end

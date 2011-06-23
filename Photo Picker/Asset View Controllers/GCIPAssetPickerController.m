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

#import <MessageUI/MessageUI.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "GCIPAssetPickerController.h"
#import "GCIPAssetPickerCell.h"

#import "GCImagePickerController.h"

#import "ALAssetsLibrary+GCImagePickerControllerAdditions.h"

@interface GCIPAssetPickerController (private)
- (void)reloadTitle;
- (void)reloadAssets;
- (void)reloadAssetsWithGroupIdentifier:(NSString *)identifier;
@end

@implementation GCIPAssetPickerController (private)
- (void)reloadTitle {
    self.title = groupName;
}
- (void)reloadAssets {
    [self reloadAssetsWithGroupIdentifier:self.groupIdentifier];
}
- (void)reloadAssetsWithGroupIdentifier:(NSString *)identifier {
    ALAssetsGroup *group = nil;
    NSError *error = nil;
    [allAssets release];
    allAssets = [[self.imagePickerController.assetsLibrary
                  gc_assetsInGroupWithIdentifier:identifier
                  filter:[ALAssetsFilter allAssets]
                  group:&group
                  error:&error] copy];
    [groupName release];
    groupName = [[group valueForProperty:ALAssetsGroupPropertyName] copy];
    [self reloadTitle];
}
@end

@implementation GCIPAssetPickerController

@synthesize groupIdentifier=_groupIdentifier;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        if (GC_IS_IPAD) { numberOfAssetsPerRow = 6; }
        else { numberOfAssetsPerRow = 4; }
    }
    return self;
}
- (void)dealloc {
    [selectedAssetURLs release];
    selectedAssetURLs = nil;
    [allAssets release];
    allAssets = nil;
    [groupName release];
    groupName = nil;
    self.groupIdentifier = nil;
    [super dealloc];
}

#pragma mark - view lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadAssets];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInset = UIEdgeInsetsMake(GCIPAssetViewPadding, 0.0, 0.0, 0.0);
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(tableDidReceiveTap:)];
    [self.tableView addGestureRecognizer:gesture];
    [gesture release];
}

#pragma mark - accessors
- (void)setGroupIdentifier:(NSString *)identifier {
    
    // check value
    if ([identifier isEqualToString:_groupIdentifier]) {
        return;
    }
    
    // set
    [_groupIdentifier release];
    _groupIdentifier = [identifier copy];
    
    // check value
    if (_groupIdentifier == nil) {
        return;
    }
    
    // reload
    if ([self isViewLoaded]) {
        [self reloadAssetsWithGroupIdentifier:_groupIdentifier];
    }
    
}

#pragma mark - table view
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ceilf((float)[allAssets count] / (float)numberOfAssetsPerRow);
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat size = [GCIPAssetPickerCell
                    sizeForNumberOfAssetsPerRow:numberOfAssetsPerRow
                    inView:tableView];
    return size + GCIPAssetViewPadding;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const identifier = @"CellIdentifier";
    GCIPAssetPickerCell *cell = (GCIPAssetPickerCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[GCIPAssetPickerCell alloc] initWithNumberOfAssets:numberOfAssetsPerRow identifier:identifier] autorelease];
    }
    NSUInteger start = indexPath.row * numberOfAssetsPerRow;
    NSUInteger length = MIN([allAssets count] - start, numberOfAssetsPerRow);
    NSRange range = NSMakeRange(start, length);
    [cell setAssets:[allAssets subarrayWithRange:range] selected:selectedAssetURLs];
    return cell;
}

#pragma mark - button actions
- (void)action:(UIBarButtonItem *)sender {
    UIActionSheet *sheet = [[UIActionSheet alloc] init];
    sheet.delegate = self;
    if (YES) {
        [sheet addButtonWithTitle:@"UPLOAD"];
    }
    if ([selectedAssetURLs count] < 6 && [MFMailComposeViewController canSendMail]) {
        [sheet addButtonWithTitle:[GCImagePickerController localizedString:@"EMAIL"]];
    }
    if ([selectedAssetURLs count] < 6) {
        [sheet addButtonWithTitle:[GCImagePickerController localizedString:@"COPY"]];
    }
    if (GC_IS_IPAD) {
        [sheet showFromBarButtonItem:sender animated:YES];
    }
    else {
        [sheet addButtonWithTitle:@"CANCEL"];
        sheet.cancelButtonIndex = (sheet.numberOfButtons - 1);
        [sheet showInView:self.view.window];
    }
    [sheet release];
}
- (void)cancel {
    [selectedAssetURLs release];
    selectedAssetURLs = nil;
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = nil;
    [self.tableView reloadData];
    [self reloadTitle];
}

#pragma mark - gestures
- (void)tableDidReceiveTap:(UITapGestureRecognizer *)gesture {
    CGPoint location = [gesture locationInView:gesture.view];
    CGFloat tileSize = [GCIPAssetPickerCell
                        sizeForNumberOfAssetsPerRow:numberOfAssetsPerRow
                        inView:gesture.view];
    NSUInteger column = 0;
    if (location.x > tileSize + GCIPAssetViewPadding) {
        column = MIN(location.x / (tileSize + GCIPAssetViewPadding),
                     numberOfAssetsPerRow - 1);
    }
    NSUInteger row = 0;
    if (location.y > tileSize + GCIPAssetViewPadding) {
        row = (location.y / (tileSize + GCIPAssetViewPadding));
    }
    NSUInteger index = row * numberOfAssetsPerRow + column;
    if (index < [allAssets count]) {
        ALAsset *asset = [allAssets objectAtIndex:index];
        ALAssetRepresentation *representation = [asset defaultRepresentation];
        NSURL *defaultURL = [representation url];
        if (selectedAssetURLs == nil) {
            selectedAssetURLs = [[NSMutableSet alloc] initWithCapacity:1];
            UIBarButtonItem *item;
            item = [[UIBarButtonItem alloc]
                    initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                    target:self
                    action:@selector(action:)];
            self.navigationItem.rightBarButtonItem = item;
            [item release];
            item = [[UIBarButtonItem alloc]
                    initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                    target:self
                    action:@selector(cancel)];
            self.navigationItem.leftBarButtonItem = item;
            [item release];
        }
        if ([selectedAssetURLs containsObject:defaultURL]) {
            [selectedAssetURLs removeObject:defaultURL];
        }
        else {
            [selectedAssetURLs addObject:defaultURL];
        }
        if ([selectedAssetURLs count] == 0) {
            [self cancel];
        }
        [self reloadTitle];
        NSArray *paths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:row inSection:0]];
        [self.tableView reloadRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark - action sheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:[GCImagePickerController localizedString:@"COPY"]]) {
        UIPasteboard *board = [UIPasteboard generalPasteboard];
        NSMutableArray *images = [NSMutableArray arrayWithCapacity:[selectedAssetURLs count]];
        for (NSURL *URL in selectedAssetURLs) {
            [self.imagePickerController.assetsLibrary
             assetForURL:URL
             resultBlock:^(ALAsset *asset) {
                 ALAssetRepresentation *rep = [asset defaultRepresentation];
                 UIImage *image = [[UIImage alloc] initWithCGImage:[rep fullScreenImage]];
                 [images addObject:image];
                 [image release];
             }
             failureBlock:^(NSError *error) {
                 NSLog(@"%@", error);
             }];
        }
        board.images = images;
    }
    else if ([title isEqualToString:[GCImagePickerController localizedString:@"EMAIL"]]) {
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        NSUInteger index = 0;
        for (NSURL *URL in selectedAssetURLs) {
            [self.imagePickerController.assetsLibrary
             assetForURL:URL
             resultBlock:^(ALAsset *asset) {
                 ALAssetRepresentation *rep = [asset defaultRepresentation];
                 UIImage *image = [[UIImage alloc] initWithCGImage:[rep fullScreenImage]];
                 [mail
                  addAttachmentData:UIImagePNGRepresentation(image)
                  mimeType:[GCImagePickerController MIMETypeForUTI:kUTTypePNG]
                  fileName:[NSString stringWithFormat:@"Item %lu", index]];
                 [image release];
             }
             failureBlock:^(NSError *error) {
                 NSLog(@"%@", error);
             }];
        }
        [self presentModalViewController:mail animated:YES];
    }
    else if ([title isEqualToString:@"UPLOAD"]) {
        
    }
}

@end

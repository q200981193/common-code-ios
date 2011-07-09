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

#import <MobileCoreServices/MobileCoreServices.h>

#import "GCIPAssetPickerController.h"
#import "GCIPAssetPickerCell.h"

#import "GCImagePickerController.h"

#import "ALAssetsLibrary+GCImagePickerControllerAdditions.h"

@interface GCIPAssetPickerController (private)
- (void)updateTitle;
@end

@implementation GCIPAssetPickerController (private)
- (void)updateTitle {
    NSUInteger count = [selectedAssetURLs count];
    if (count == 1) {
        self.title = [GCImagePickerController localizedString:@"PHOTO_COUNT_SINGLE"];
    }
    else if (count > 1) {
        self.title = [NSString stringWithFormat:
                      [GCImagePickerController localizedString:@"PHOTO_COUNT_MULTIPLE"],
                      count];
    }
    else {
        self.title = groupName;
    }
}
@end

@implementation GCIPAssetPickerController

#pragma mark - object methods
- (id)initWithAssetsGroupIdentifier:(NSString *)identifier {
    NSAssert([identifier length], @"Group identifier cannot be left blank");
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        groupIdentifier = [identifier copy];
        if (GC_IS_IPAD) { numberOfAssetsPerRow = 6; }
        else { numberOfAssetsPerRow = 4; }
        self.editing = NO;
    }
    return self;
}
- (void)dealloc {
    [selectedAssetURLs release]; selectedAssetURLs = nil;
    [allAssets release]; allAssets = nil;
    [groupName release]; groupName = nil;
    [groupIdentifier release]; groupIdentifier = nil;
    [super dealloc];
}
- (void)reloadAssets {
    if ([self isViewLoaded]) {
        
        // load assets
        ALAssetsGroup *group = nil;
        NSError *error = nil;
        [allAssets release];
        allAssets = [[self.imagePickerController.assetsLibrary
                      gc_assetsInGroupWithIdentifier:groupIdentifier
                      filter:[ALAssetsFilter allAssets]
                      group:&group
                      error:&error] copy];
        
        // error check
        if (!group) {
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        else if (error) {
            ALAssetsLibraryAccessFailureBlock block = GCImagePickerControllerLibraryFailureBlock();
            block(error);
        }
        
        // get group name
        [groupName release];
        groupName = [[group valueForProperty:ALAssetsGroupPropertyName] copy];
        
        // table visibility
        self.tableView.hidden = (![allAssets count]);
        
        // trigger a reload
        self.editing = NO;
        
    }
}

#pragma mark - view lifecycle
- (void)viewDidLoad {
    
    // super
    [super viewDidLoad];
    
    // table view
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInset = UIEdgeInsetsMake(GCIPAssetViewPadding, 0.0, 0.0, 0.0);
    self.tableView.contentOffset = CGPointMake(0.0, -GCIPAssetViewPadding);
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(tableDidReceiveTap:)];
    [self.tableView addGestureRecognizer:gesture];
    [gesture release];
    
    // reload
    [self reloadAssets];
    
}
- (void)viewDidUnload {
    [super viewDidUnload];
    self.editing = NO;
}

#pragma mark - button actions
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
    // release stuff
    [selectedAssetURLs release];
    
    if (editing) {
        
        // create stuff
        selectedAssetURLs = [[NSMutableSet alloc] init];
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
    else {
        
        // release stuff
        selectedAssetURLs = nil;
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.leftBarButtonItem = nil;
        
    }
    
    // reload stuff
    [self updateTitle];
    [self.tableView reloadData];
    if (sheet) {
        [sheet dismissWithClickedButtonIndex:sheet.cancelButtonIndex animated:animated];
        sheet = nil;
    }
    
}
- (void)action:(UIBarButtonItem *)sender {
    if (!sheet) {
        sheet = [[UIActionSheet alloc] init];
        sheet.delegate = self;
        GCImagePickerViewController *controller = self.imagePickerController;
        if (controller.actionEnabled && controller.actionTitle) {
            [sheet addButtonWithTitle:controller.actionTitle];
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
            [sheet addButtonWithTitle:[GCImagePickerController localizedString:@"CANCEL"]];
            sheet.cancelButtonIndex = (sheet.numberOfButtons - 1);
            [sheet showInView:self.view];
        }
        [sheet release];
    }
}
- (void)cancel {
    self.editing = NO;
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
        
        // get asset stuff
        ALAsset *asset = [allAssets objectAtIndex:index];
        ALAssetRepresentation *representation = [asset defaultRepresentation];
        NSURL *defaultURL = [representation url];
        
        // enter select mode
        if (!self.editing) {
            self.editing = YES;
        }
        
        // modify set
        if ([selectedAssetURLs containsObject:defaultURL]) {
            [selectedAssetURLs removeObject:defaultURL];
        }
        else {
            [selectedAssetURLs addObject:defaultURL];
        }
        
        // check set count
        if (![selectedAssetURLs count]) {
            self.editing = NO;
        }
        else {
            GCImagePickerViewController *controller = self.imagePickerController;
            BOOL action = (controller.actionTitle && controller.actionEnabled);
            BOOL count = ([selectedAssetURLs count] < 6);
            self.navigationItem.rightBarButtonItem.enabled = (action || count);
        }
        
        // reload
        [self updateTitle];
        NSArray *paths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:row inSection:0]];
        [self.tableView reloadRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationNone];
        
    }
}

#pragma mark - mail compose
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    if (result != MFMailComposeResultFailed && result != MFMailComposeResultCancelled) {
        self.editing = NO;
    }
    [controller dismissModalViewControllerAnimated:YES];
}

#pragma mark - action sheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    // release sheet
    sheet = nil;
    
    // cancel
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    // bounds check
    if (buttonIndex < 0 || buttonIndex >= actionSheet.numberOfButtons) {
        return;
    }
    
    // get resources
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    GCImagePickerViewController *controller = self.imagePickerController;
    
    // copy
    if ([title isEqualToString:[GCImagePickerController localizedString:@"COPY"]]) {
        NSMutableArray *images = [[NSMutableArray alloc] initWithCapacity:[selectedAssetURLs count]];
        [selectedAssetURLs enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
            [controller.assetsLibrary
             assetForURL:obj
             resultBlock:^(ALAsset *asset) {
                 ALAssetRepresentation *rep = [asset defaultRepresentation];
                 UIImage *image = [[UIImage alloc] initWithCGImage:[rep fullScreenImage]];
                 [images addObject:image];
                 [image release];
             }
             failureBlock:^(NSError *error) {
                 GC_LOG_NSERROR(error);
             }];
        }];
        [[UIPasteboard generalPasteboard] setImages:images];
        [images release];
        self.editing = NO;
    }
    
    // email
    else if ([title isEqualToString:[GCImagePickerController localizedString:@"EMAIL"]]) {
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        __block unsigned long index = 0;
        [selectedAssetURLs enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
            [controller.assetsLibrary
             assetForURL:obj
             resultBlock:^(ALAsset *asset) {
                 ALAssetRepresentation *rep = [asset defaultRepresentation];
                 NSData *data = [GCImagePickerController dataForAssetRepresentation:rep];
                 [mail
                  addAttachmentData:data
                  mimeType:[GCImagePickerController MIMETypeForAssetRepresentation:rep]
                  fileName:[NSString stringWithFormat:@"Item %lu", index++]];
             }
             failureBlock:^(NSError *error) {
                 NSLog(@"%@", error);
             }];
        }];
        [self presentModalViewController:mail animated:YES];
        [mail release];
    }
    
    // action
    else if ([title isEqualToString:controller.actionTitle]) {
        [selectedAssetURLs enumerateObjectsUsingBlock:controller.actionBlock];
        self.editing = NO;
    }
    
}

@end

//
//  GCImageSlideshowController.m
//  GUI Cocoa Common Code Library for iOS
//
//  Created by Caleb Davenport on 3/26/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import "GCImageSlideshowController.h"

@interface GCImageSlideshowController (private)
- (void)reloadData;
- (NSUInteger)currentPage;
- (void)scrollToPageAtIndex:(NSUInteger)index;
- (UIView *)pageForIndex:(NSUInteger)index;
@end

@implementation GCImageSlideshowController (private)
- (void)reloadData {
    NSUInteger count = [assets count];
    self.scrollView.contentSize = CGSizeMake(count * self.view.bounds.size.width, self.view.bounds.size.height);
    self.scrollView.contentOffset = CGPointZero;
    for (NSUInteger i = 0; i < MIN(5, [assets count]); i++) {
        ALAsset *asset = [assets objectAtIndex:i];
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        CGImageRef imageRef = [rep fullScreenImage];
        UIImage *image = [[UIImage alloc] initWithCGImage:imageRef scale:[rep scale] orientation:[rep orientation]];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.backgroundColor = [UIColor redColor];
        imageView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.frame = CGRectMake(i * self.scrollView.bounds.size.width, 0,
                                     self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
        [self.scrollView addSubview:imageView];
        [imageView release];
        [image release];
    }
}
- (NSUInteger)currentPage {
    return (self.scrollView.contentOffset.x / self.scrollView.bounds.size.width);
}
- (void)scrollToPageAtIndex:(NSUInteger)index {
    CGRect dest = CGRectMake(index * self.scrollView.bounds.size.width,
                             0, self.scrollView.bounds.size.width,
                             self.scrollView.bounds.size.height);
    [self.scrollView scrollRectToVisible:dest animated:YES];
}
- (UIView *)pageForIndex:(NSUInteger)index {
    
}
@end

@implementation GCImageSlideshowController

@synthesize scrollView=_scrollView;

#pragma mark - object lifecycle
- (id)initWithAssets:(NSArray *)array {
    self = [super initWithNibName:@"GCImageSlideshowController" bundle:nil];
    if (self) {
        assets = [array retain];
        library = [[ALAssetsLibrary alloc] init];
    }
    return self;
}
- (void)dealloc {
    [library release];
    library = nil;
    [assets release];
    assets = nil;
    [views release];
    views = nil;
    self.scrollView = nil;
    [super dealloc];
}

#pragma mark - view lifecycle
- (void)viewDidUnload {
    [super viewDidUnload];
    [views release];
    views = nil;
    self.scrollView = nil;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    views = [[NSMutableArray alloc] initWithCapacity:5];
    [self reloadData];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return (UIInterfaceOrientationIsLandscape(orientation) || orientation == UIInterfaceOrientationPortrait);
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration {
    NSUInteger current = [self currentPage];
    CGRect bounds = [[UIScreen mainScreen] bounds];
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        self.scrollView.contentSize = CGSizeMake(bounds.size.height * [assets count], bounds.size.width);
    }
    else {
        self.scrollView.contentSize = CGSizeMake(bounds.size.width * [assets count], bounds.size.height);
    }
    [self scrollToPageAtIndex:current];
}

#pragma mark - interface builder actions
- (IBAction)next {
    NSUInteger current = [self currentPage];
    [self scrollToPageAtIndex:(current + 1)];
}
- (IBAction)previous {
    NSUInteger current = [self currentPage];
    [self scrollToPageAtIndex:(current - 1)];
}
- (IBAction)action {
    
}

#pragma mark - scroll view
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    GC_LOG_INFO(@"");
}

@end

//
//  GCImageSlideshowController.m
//  GUI Cocoa Common Code Library for iOS
//
//  Created by Caleb Davenport on 3/26/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import "GCImageSlideshowController.h"
#import "GCContentScrollView.h"

@interface GCImageSlideshowController (private)

// heavy lifter
- (void)tilePages;

// maintain page cache
- (GCContentScrollView *)dequeuePage;
- (void)configurePage:(GCContentScrollView *)page forIndex:(NSUInteger)index;

// utility methods
- (CGSize)contentSizeForPagingScrollView;
- (CGRect)frameForPageAtIndex:(NSUInteger)index;
- (BOOL)isDisplayingPageForIndex:(NSInteger)index;

// no clue
- (void)reloadData;

@end

@implementation GCImageSlideshowController (private)
- (void)tilePages {
    
    // get index range to cache
    CGRect bounds = self.scrollView.bounds;
    NSInteger firstIndex = floorf(CGRectGetMinX(bounds) / CGRectGetWidth(bounds));
    NSInteger lastIndex  = floorf((CGRectGetMaxX(bounds) - 1) / CGRectGetWidth(bounds));
    firstIndex = MAX(firstIndex - 1, 0);
    lastIndex  = MIN(lastIndex + 1, [assets count] - 1);
    
    // recycle off-screen pages
    for (GCContentScrollView *page in visiblePages) {
        if (page.index < firstIndex || page.index > lastIndex) {
            [recycledPages addObject:page];
            [page removeFromSuperview];
        }
    }
    [visiblePages minusSet:recycledPages];
    
    // add missing pages
    for (NSInteger index = firstIndex; index <= lastIndex; index++) {
        if (![self isDisplayingPageForIndex:index]) {
            GCContentScrollView *page = [self dequeuePage];
            if (page == nil) {
                page = [[[GCContentScrollView alloc] init] autorelease];
            }
            [self configurePage:page forIndex:index];
            [self.scrollView addSubview:page];
            [visiblePages addObject:page];
        }
    }
    
}
- (GCContentScrollView *)dequeuePage {
    GCContentScrollView *page = [recycledPages anyObject];
    if (page != nil) {
        [[page retain] autorelease];
        [recycledPages removeObject:page];
    }
    return page;
}
- (void)configurePage:(GCContentScrollView *)page forIndex:(NSUInteger)index {
    
    // log
    GC_LOG_INFO(@"begin configure page");
    
    // configure frame
    page.index = index;
    page.frame = [self frameForPageAtIndex:index];
    
    // configure image
    ALAsset *asset = [assets objectAtIndex:index];
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    float scale = [rep scale];
    ALAssetOrientation orientation = [rep orientation];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CGImageRef imageRef = [rep fullScreenImage];
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (page.index == index) {
                UIImage *image = [[UIImage alloc] initWithCGImage:imageRef scale:scale orientation:orientation];
                UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
                page.view = imageView;
                [imageView release];
                [image release];
                GC_LOG_INFO(@"end configure page");
            }
            else {
                GC_LOG_INFO(@"ignoring page");
            }
        });
    });
    
}
- (CGSize)contentSizeForPagingScrollView {
    CGRect bounds = self.scrollView.bounds;
    return CGSizeMake(bounds.size.width * [assets count], bounds.size.height);
}
- (CGRect)frameForPageAtIndex:(NSUInteger)index {
    CGRect bounds = self.scrollView.bounds;
    CGFloat padding = fabsf(self.scrollView.frame.origin.x);
    CGRect pageFrame = bounds;
    pageFrame.size.width -= (padding * 2.0);
    pageFrame.origin.x = (bounds.size.width * index) + padding;
    return pageFrame;
}
- (BOOL)isDisplayingPageForIndex:(NSInteger)index {
    BOOL retVal = NO;
    for (GCContentScrollView *page in visiblePages) {
        if (page.index == index) {
            retVal = YES;
            break;
        }
    }
    return retVal;
}
- (void)reloadData {
    
}
@end

@implementation GCImageSlideshowController

@synthesize scrollView=_scrollView;
@synthesize toolbar=_toolbar;

#pragma mark - object lifecycle
- (id)initWithAssets:(NSArray *)array {
    self = [super initWithNibName:@"GCImageSlideshowController" bundle:nil];
    if (self) {
        
        // assets library
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
    [visiblePages release];
    visiblePages = nil;
    [recycledPages release];
    recycledPages = nil;
    self.scrollView = nil;
    self.toolbar = nil;
    [super dealloc];
}

#pragma mark - view lifecycle
- (void)viewDidUnload {
    [super viewDidUnload];
    [visiblePages release];
    visiblePages = nil;
    [recycledPages release];
    recycledPages = nil;
    self.scrollView = nil;
    self.toolbar = nil;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // create sets
    visiblePages = [[NSMutableSet alloc] init];
    recycledPages = [[NSMutableSet alloc] init];
    
    // set initial content size
    self.scrollView.contentSize = [self contentSizeForPagingScrollView];
    
    // load first page
//    if ([assets count] > 0) {
//        GCContentScrollView *page = [[GCContentScrollView alloc] init];
//        [self configurePage:page forIndex:0];
//        [visiblePages addObject:page];
//        [self.scrollView addSubview:page];
//        [page release];
//    }
    [self tilePages];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return (UIInterfaceOrientationIsLandscape(orientation) || orientation == UIInterfaceOrientationPortrait);
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration {
//    CGFloat offset = pagingScrollView.contentOffset.x;
//    CGFloat pageWidth = pagingScrollView.bounds.size.width;
//    
//    if (offset >= 0) {
//        firstVisiblePageIndexBeforeRotation = floorf(offset / pageWidth);
//        percentScrolledIntoFirstVisiblePage = (offset - (firstVisiblePageIndexBeforeRotation * pageWidth)) / pageWidth;
//    } else {
//        firstVisiblePageIndexBeforeRotation = 0;
//        percentScrolledIntoFirstVisiblePage = offset / pageWidth;
//    }
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration {
    self.scrollView.contentSize = [self contentSizeForPagingScrollView];
    for (GCContentScrollView *page in visiblePages) {
        CGPoint center = [page pointToRestoreAfterRotation];
        CGFloat scale = [page scaleToRestoreAfterRotation];
        page.frame = [self frameForPageAtIndex:page.index];
        [page centerView];
        [page updateZoomLimits];
        [page restorePoint:center scale:scale];
    }
//    CGFloat pageWidth = pagingScrollView.bounds.size.width;
//    CGFloat newOffset = (firstVisiblePageIndexBeforeRotation * pageWidth) + (percentScrolledIntoFirstVisiblePage * pageWidth);
//    pagingScrollView.contentOffset = CGPointMake(newOffset, 0);
}
- (UIView *)rotatingFooterView {
    return self.toolbar;
}

#pragma mark - interface builder actions
- (IBAction)next {
//    NSUInteger current = [self currentPage];
//    [self scrollToPageAtIndex:(current + 1)];
}
- (IBAction)previous {
//    NSUInteger current = [self currentPage];
//    [self scrollToPageAtIndex:(current - 1)];
}
- (IBAction)action {
    
}

#pragma mark - scroll view
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self tilePages];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    GC_LOG_INFO(@"");
}

@end

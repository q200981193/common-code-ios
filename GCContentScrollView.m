//
//  GCContentScrollView.m
//  GUI Cocoa Common Code Library for iOS
//
//  Created by Caleb Davenport on 3/27/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import "GCContentScrollView.h"

@implementation GCContentScrollView

@synthesize view=_view;
@synthesize index=_index;

#pragma mark - object lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.bouncesZoom = YES;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.delegate = self;
        self.minimumZoomScale = 1.0;
        self.maximumZoomScale = 1.0;
        self.alwaysBounceVertical = NO;
        self.alwaysBounceHorizontal = NO;
    }
    return self;
}
- (void)dealloc {
    self.view = nil;
    [super dealloc];
}

#pragma mark - accessors
- (void)setView:(UIView *)newView {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_view release];
    _view = [newView retain];
    if (_view != nil) {
        self.zoomScale = 1.0;
        [self addSubview:_view];
        self.contentSize = _view.bounds.size;
        [self updateZoomLimits];
        self.zoomScale = self.minimumZoomScale;
        [self setNeedsLayout];
    }
}

#pragma mark - layout
- (void)layoutSubviews {
    [super layoutSubviews];
    [self centerView];
}
- (void)updateZoomLimits {
    
    // get vars
    CGSize boundsSize = self.bounds.size;
    CGSize contentSize = self.view.bounds.size;
    
    // determine smallest scale
    CGFloat xScale = boundsSize.width / contentSize.width;
    CGFloat yScale = boundsSize.height / contentSize.height;
    CGFloat minScale = MIN(xScale, yScale);
    self.minimumZoomScale = minScale;
    if (minScale > self.maximumZoomScale) {
        self.maximumZoomScale = minScale;
    }
    
}
- (CGPoint)pointToRestoreAfterRotation {
    CGPoint boundsCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    return [self convertPoint:boundsCenter toView:self.view];
}
- (CGFloat)scaleToRestoreAfterRotation {
    CGFloat contentScale = self.zoomScale;
    if (contentScale <= self.minimumZoomScale + FLT_EPSILON) {
        contentScale = 0;
    }
    return contentScale;
}
- (CGPoint)maximumContentOffset {
    CGSize contentSize = self.contentSize;
    CGSize boundsSize = self.bounds.size;
    return CGPointMake(contentSize.width - boundsSize.width, contentSize.height - boundsSize.height);
}

- (CGPoint)minimumContentOffset {
    return CGPointZero;
}
- (void)restorePoint:(CGPoint)point scale:(CGFloat)scale {
    
    // Step 1: restore zoom scale, first making sure it is within the allowable range.
    self.zoomScale = MIN(self.maximumZoomScale, MAX(self.minimumZoomScale, scale));
    
    // Step 2: restore center point, first making sure it is within the allowable range.
    
    // 2a: convert our desired center point back to our own coordinate space
    CGPoint boundsCenter = [self convertPoint:point fromView:self.view];
    
    // 2b: calculate the content offset that would yield that center point
    CGPoint offset = CGPointMake(boundsCenter.x - self.bounds.size.width / 2.0, boundsCenter.y - self.bounds.size.height / 2.0);
    
    // 2c: restore offset, adjusted to be within the allowable range
    CGPoint maxOffset = [self maximumContentOffset];
    CGPoint minOffset = [self minimumContentOffset];
    offset.x = MAX(minOffset.x, MIN(maxOffset.x, offset.x));
    offset.y = MAX(minOffset.y, MIN(maxOffset.y, offset.y));
    self.contentOffset = offset;
    
}
- (void)centerView {
    
    // get vars
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = self.view.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2.0;
    }
    else {
        frameToCenter.origin.x = 0.0;
    }
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2.0;
    }
    else {
        frameToCenter.origin.y = 0.0;
    }
    
    // set
    self.view.frame = frameToCenter;
    
}

#pragma mark - scroll view delegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.view;
}

@end

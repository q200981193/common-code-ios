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

#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "GCImageGridAssetView.h"

#define kThumbnailViewTag 1
#define kSelectedViewTag 2
#define kVideoViewTag 3

@implementation GCImageGridAssetView

@synthesize asset=_asset;
@synthesize selected=_selected;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [[self layer] setBorderColor:[[UIColor colorWithWhite:0.0 alpha:0.25] CGColor]];
        [[self layer] setBorderWidth:1.0];
        [self setAutoresizesSubviews:NO];
    }
    return self;
}
- (void)dealloc {
    self.asset = nil;
    [super dealloc];
}
- (void)setAsset:(ALAsset *)newAsset {
    
    // set value
    [_asset release];
    _asset = [newAsset retain];
    
    // get thumbnail view
    UIImageView *thumbnailView = (UIImageView *)[self viewWithTag:kThumbnailViewTag];
    
    // set views
    if (_asset) {
        
        // self
        self.hidden = NO;
        
        // thumbnail view
        if (thumbnailView == nil) {
            thumbnailView = [[UIImageView alloc] initWithFrame:CGRectZero];
            thumbnailView.tag = kThumbnailViewTag;
            [self addSubview:thumbnailView];
            [thumbnailView release];
        }
        UIImage *thumbnail = [UIImage imageWithCGImage:[_asset thumbnail]];
        thumbnailView.image = thumbnail;
        
        // video view
        UIImageView *videoView = (UIImageView *)[self viewWithTag:kVideoViewTag];
        NSString *assetType = [_asset valueForProperty:ALAssetPropertyType];
        if ([assetType isEqualToString:ALAssetTypeVideo]) {
            if (videoView == nil) {
                UIImage *videoImage = [UIImage imageNamed:@"GCImagePickerControllerVideoAsset"];
                videoView = [[UIImageView alloc] initWithFrame:CGRectZero];
                [[videoView layer] setBackgroundColor:[[UIColor colorWithWhite:0.0 alpha:0.25] CGColor]];
                videoView.contentMode = UIViewContentModeLeft;
                videoView.tag = kVideoViewTag;
                videoView.image = videoImage;
                [self addSubview:videoView];
                [videoView release];
            }
        }
        else {
            [videoView removeFromSuperview];
        }
        
    }
    
    // clear views
    else {
        self.hidden = YES;
        self.selected = NO;
        [thumbnailView removeFromSuperview];
    }
    
    // set needs layout
    [self setNeedsLayout];
    
}
- (void)setSelected:(BOOL)selected {
    if (self.selected != selected) {
        _selected = selected;
        UIImageView *imageView = (UIImageView *)[self viewWithTag:kSelectedViewTag];
        if (_selected) {
            if (imageView == nil) {
                imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
                [imageView setTag:kSelectedViewTag];
                [imageView setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.5]];
                [imageView setContentMode:UIViewContentModeBottomRight];
                [imageView setImage:[UIImage imageNamed:@"GCImagePickerControllerCheckGreen"]];
                [self addSubview:imageView];
                [imageView release];
            }
            [self bringSubviewToFront:imageView];
        }
        else {
            [imageView removeFromSuperview];
        }
    }
}
- (void)layoutSubviews {
    [super layoutSubviews];
    
    // thumbnail view
    UIView *thumbnailView = [self viewWithTag:kThumbnailViewTag];
    thumbnailView.frame = self.bounds;
    
    // video view
    UIImageView *videoView = (UIImageView *)[self viewWithTag:kVideoViewTag];
    if (videoView) {
        UIImage *videoImage = videoView.image;
        videoView.frame = CGRectMake(1, self.bounds.size.height - videoImage.size.height - 1,
                                     self.bounds.size.width - 2, videoImage.size.height);
        [self bringSubviewToFront:videoView];
    }
    
    // selected view
    UIView *selectedView = [self viewWithTag:kSelectedViewTag];
    if (selectedView) {
        selectedView.frame = CGRectMake(1, 1, self.bounds.size.width - 2, self.bounds.size.height - 2);
        [self bringSubviewToFront:selectedView];
    }
}

@end

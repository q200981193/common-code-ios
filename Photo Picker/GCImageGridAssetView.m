//
//  GCImageGridAssetView.m
//  GUI Cocoa Common Code Library for iOS
//
//  Created by Caleb Davenport on 3/17/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

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
    [self willChangeValueForKey:@"asset"];
    
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
                UIImage *videoImage = [UIImage imageNamed:@"VideoAsset"];
                videoImage = [videoImage stretchableImageWithLeftCapWidth:(videoImage.size.width - 2) topCapHeight:0];
                videoView = [[UIImageView alloc] initWithFrame:CGRectZero];
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
    
    [self didChangeValueForKey:@"asset"];
}
- (void)setSelected:(BOOL)selected {
    if (self.selected != selected) {
        [self willChangeValueForKey:@"selected"];
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
        [self didChangeValueForKey:@"selected"];
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
        videoView.frame = CGRectMake(0, self.bounds.size.height - videoImage.size.height,
                                     self.bounds.size.width, videoImage.size.height);
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

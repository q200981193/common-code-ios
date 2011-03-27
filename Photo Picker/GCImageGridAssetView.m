//
//  GCImageGridAssetView.m
//  GUI Cocoa Common Code Library for iOS
//
//  Created by Caleb Davenport on 3/17/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "GCImageGridAssetView.h"

#define kImageViewTag 1
#define kSelectedViewTag 2

@implementation GCImageGridAssetView

@synthesize asset=_asset;
@synthesize selected=_selected;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        // my layer
        [[self layer] setBorderColor:[[UIColor colorWithWhite:0.0 alpha:0.25] CGColor]];
        [[self layer] setBorderWidth:1.0];
        
    }
    return self;
}
- (void)dealloc {
    self.asset = nil;
    [super dealloc];
}
- (void)setAsset:(ALAsset *)newAsset {
    [_asset release];
    _asset = [newAsset retain];
    UIImageView *thumbnailView = (UIImageView *)[self viewWithTag:kImageViewTag];
    if (_asset == nil) {
        self.hidden = YES;
        self.selected = NO;
        [thumbnailView removeFromSuperview];
    }
    else {
        
        // self
        self.hidden = NO;
        
        // thumbnail view
        if (thumbnailView == nil) {
            thumbnailView = [[UIImageView alloc] initWithFrame:[self bounds]];
            [thumbnailView setTag:kImageViewTag];
            [self addSubview:thumbnailView];
            [thumbnailView release];
        }
        UIImage *thumbnail = [UIImage imageWithCGImage:[_asset thumbnail]];
        [thumbnailView setImage:thumbnail];
        
        // video views
        NSString *type = [_asset valueForProperty:ALAssetPropertyType];
        if ([type isEqualToString:ALAssetTypeVideo]) {
//            UIImage *image = [UIImage imageNamed:@"VideoOverlay"];
//            image = [image stretchableImageWithLeftCapWidth:36 topCapHeight:0];
//            video = [[UIImageView alloc] initWithImage:image];
//            video.tag = base + 8;
//            video.frame = CGRectMake(tile.frame.origin.x,
//                                     tile.frame.origin.y + tile.frame.size.height - image.size.height,
//                                     tile.frame.size.width,
//                                     image.size.height);
//            [cell.contentView addSubview:video];
//            [video release];
        }
        else {
            
        }
        
    }
}
- (void)setSelected:(BOOL)newSelected {
    _selected = newSelected;
    UIImageView *imageView = (UIImageView *)[self viewWithTag:kSelectedViewTag];
    if (_selected) {
        if (imageView == nil) {
            CGRect frame = CGRectMake(1, 1, self.bounds.size.width - 2, self.bounds.size.height - 2);
            imageView = [[UIImageView alloc] initWithFrame:frame];
            [imageView setTag:kSelectedViewTag];
            [imageView setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.5]];
            [imageView setContentMode:UIViewContentModeBottomRight];
            [imageView setImage:[UIImage imageNamed:@"GCImagePickerControllerCheckGreen"]];
            [self addSubview:imageView];
            [self bringSubviewToFront:imageView];
            [imageView release];
        }
    }
    else {
        [imageView removeFromSuperview];
    }
}

@end

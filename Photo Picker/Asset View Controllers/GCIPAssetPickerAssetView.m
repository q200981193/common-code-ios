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

#import "GCIPAssetPickerAssetView.h"

@implementation GCIPAssetPickerAssetView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        // base properties
        self.layer.borderColor = [[UIColor colorWithWhite:0.0 alpha:0.25] CGColor];
        self.layer.borderWidth = 1.0;
        self.autoresizesSubviews = NO;
        
        // thumbnail view
        thumbnailView = [[UIImageView alloc] init];
        [self addSubview:thumbnailView];
        
        // video icon view
        videoIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GCImagePickerControllerVideoAsset"]];
        videoIconView.layer.backgroundColor = [[UIColor colorWithWhite:0.0 alpha:0.25] CGColor];
        videoIconView.contentMode = UIViewContentModeLeft;
        [self addSubview:videoIconView];
        
        // selected icon view
        selectedIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GCImagePickerControllerCheckGreen"]];
        selectedIconView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        selectedIconView.contentMode = UIViewContentModeBottomRight;
        [self addSubview:selectedIconView];
        
    }
    return self;
}
- (void)dealloc {
    [selectedIconView release];
    selectedIconView = nil;
    [thumbnailView release];
    thumbnailView = nil;
    [videoIconView release];
    videoIconView = nil;
    [super dealloc];
}
- (void)setAsset:(ALAsset *)asset {
    
    // set views
    if (asset) {
        
        // self
        self.hidden = NO;
        
        // thumbnail view
        UIImage *thumbnailImage = [[UIImage alloc] initWithCGImage:[asset thumbnail]];
        thumbnailView.image = thumbnailImage;
        [thumbnailImage release];
        
        // video view
        NSString *assetType = [asset valueForProperty:ALAssetPropertyType];
        videoIconView.hidden = ![assetType isEqualToString:ALAssetTypeVideo];
        
    }
    
    // clear views
    else {
        self.hidden = YES;
    }
    
}
- (void)setSelected:(BOOL)selected {
    selectedIconView.hidden = !selected;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    
    // thumbnail view
    thumbnailView.frame = self.bounds;
    
    // video view
    UIImage *videoIcon = videoIconView.image;
    videoIconView.frame = CGRectMake(1.0,
                                     self.bounds.size.height - videoIcon.size.height - 1.0,
                                     self.bounds.size.width - 2.0,
                                     videoIcon.size.height);
    
    // selected view
    selectedIconView.frame = CGRectMake(1.0, 1.0, self.bounds.size.width - 2.0, self.bounds.size.height - 2.0);
}

@end

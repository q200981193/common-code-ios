//
//  GCAssetPickerCell.m
//  QuickShot
//
//  Created by Caleb Davenport on 6/14/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

#import "GCIPAssetPickerCell.h"
#import "GCIPAssetPickerAssetView.h"

CGFloat GCIPAssetViewPadding = 4.0;

@implementation GCIPAssetPickerCell

#pragma mark - class methods
+ (NSUInteger)sizeForNumberOfAssetsPerRow:(NSUInteger)count inView:(UIView *)view {
    CGFloat space = ((count + 1) * 4);
    return ((view.bounds.size.width - space) / count);   
}

#pragma mark - object methods
- (id)initWithNumberOfAssets:(NSUInteger)count identifier:(NSString *)identifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    if (self) {
        numberOfAssets = count;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}
- (void)setAssets:(NSArray *)assets selected:(NSSet *)selected {
    NSUInteger count = [assets count];
    for (NSUInteger index = 0; index < numberOfAssets; index++) {
        NSUInteger tag = index + 1;
        GCIPAssetPickerAssetView *assetView = (GCIPAssetPickerAssetView *)[self.contentView viewWithTag:tag];
        if (assetView == nil) {
            assetView = [[GCIPAssetPickerAssetView alloc] initWithFrame:CGRectZero];
            assetView.tag = tag;
            assetView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
            [self.contentView addSubview:assetView];
            [assetView release];
        }
        ALAsset *asset = nil;
        if (index < count) {
            asset = [assets objectAtIndex:index];
            NSURL *assetURL = [[asset defaultRepresentation] url];
            [assetView setSelected:[selected containsObject:assetURL]];
        }
        [assetView setAsset:asset];
    }
}
- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat tile = [GCIPAssetPickerCell sizeForNumberOfAssetsPerRow:numberOfAssets inView:self];
    CGFloat y = self.bounds.size.height - tile - GCIPAssetViewPadding;
    CGFloat innerWidth = (float)numberOfAssets * tile + ((float)numberOfAssets - 1) * GCIPAssetViewPadding;
    CGFloat outerWidth = self.bounds.size.width - innerWidth;
    __block CGFloat x = floorf(outerWidth / 2.0);
    [self.contentView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(UIView *)obj setFrame:CGRectMake(x, y, tile, tile)];
        x += (tile + GCIPAssetViewPadding);
    }];
}

@end

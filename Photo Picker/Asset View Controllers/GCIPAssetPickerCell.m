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

@interface GCIPAssetPickerCell (private)
- (CGRect)frameForAssetAtIndex:(NSUInteger)index;
@end

@implementation GCIPAssetPickerCell (private)
- (CGRect)frameForAssetAtIndex:(NSUInteger)index {
    UIView *view = self.contentView;
    CGFloat tile = [GCIPAssetPickerCell sizeForNumberOfAssetsPerRow:numberOfAssets inView:view];
    return CGRectMake(4.0 + (tile + 4.0) * (CGFloat)index,
                      view.bounds.size.height - tile - 4.0,
                      tile, tile);
}
@end

@implementation GCIPAssetPickerCell

@synthesize assets = __assets;

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
- (void)dealloc {
    self.assets = nil;
    [super dealloc];
}
- (void)setAssets:(NSArray *)assets {
    [self setAssets:assets selected:nil];
}
- (void)setAssets:(NSArray *)assets selected:(NSSet *)selected {
    [__assets release];
    __assets = [assets copy];
    NSUInteger count = [assets count];
    for (NSUInteger index = 0; index < numberOfAssets; index++) {
        NSUInteger tag = index + 1;
        GCIPAssetPickerAssetView *assetView = (GCIPAssetPickerAssetView *)[self.contentView viewWithTag:tag];
        if (assetView == nil) {
            CGRect frame = [self frameForAssetAtIndex:index];
            assetView = [[GCIPAssetPickerAssetView alloc] initWithFrame:frame];
            assetView.tag = tag;
            assetView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
            [self.contentView addSubview:assetView];
            [assetView release];
        }
        ALAsset *object = nil;
        if (index < count) {
            object = [__assets objectAtIndex:index];
            NSURL *assetURL = [[object defaultRepresentation] url];
            assetView.selected = [selected containsObject:assetURL];
        }
        assetView.asset = object;
    }
}
- (void)layoutSubviews {
    [super layoutSubviews];
    [self.contentView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(UIView *)obj setFrame:[self frameForAssetAtIndex:idx]];
    }];
}

@end

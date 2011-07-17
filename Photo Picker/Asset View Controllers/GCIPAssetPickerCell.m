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

@implementation GCIPAssetPickerCell

@synthesize numberOfColumns     = __numberOfColumns;
@synthesize columnPadding       = __columnPadding;

#pragma mark - class methods
+ (CGFloat)columnWidthForNumberOfColumns:(NSUInteger)columns withPadding:(CGFloat)padding inView:(UIView *)view {
    NSUInteger numberOfSpaces = columns + 1;
    CGFloat spaceWidth = (CGFloat)numberOfSpaces * padding;
    return (view.bounds.size.width - spaceWidth) / (CGFloat)columns;
}

#pragma mark - object methods
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}
- (void)setNumberOfColumns:(NSUInteger)count {
    
    // check for same value
    if (count == __numberOfColumns) {
        return;
    }
    
    // save value
    __numberOfColumns = count;
    
    // set needs layout
    [self setNeedsLayout];
    
}
- (void)setAssets:(NSArray *)assets selected:(NSSet *)selected {
    
    // setup stuff
    NSUInteger count = [assets count];
    
    for (NSUInteger index = 0; index < self.numberOfColumns; index++) {
        
        // get view
        NSUInteger tag = index + 1;
        GCIPAssetPickerAssetView *assetView = (GCIPAssetPickerAssetView *)[self.contentView viewWithTag:tag];
        
        // create view if we need one
        if (assetView == nil && index < count) {
            assetView = [[GCIPAssetPickerAssetView alloc] initWithFrame:CGRectZero];
            assetView.tag = tag;
//            assetView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
            [self.contentView addSubview:assetView];
            [assetView release];
        }
        
        // setup view
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
//    CGFloat tile = [GCIPAssetPickerCell sizeForNumberOfAssetsPerRow:numberOfAssets inView:self];
//    CGFloat y = self.bounds.size.height - tile - GCIPAssetViewPadding;
//    CGFloat innerWidth = (float)numberOfAssets * tile + ((float)numberOfAssets - 1) * GCIPAssetViewPadding;
//    CGFloat outerWidth = self.bounds.size.width - innerWidth;
//    __block CGFloat x = floorf(outerWidth / 2.0);
    CGFloat width = [GCIPAssetPickerCell
                     columnWidthForNumberOfColumns:self.numberOfColumns
                     withPadding:self.columnPadding
                     inView:self.contentView];
    CGFloat height = self.contentView.bounds.size.height;
    CGFloat padding = self.columnPadding;
    [self.contentView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGRect frame = CGRectMake(padding + (width + padding) * (CGFloat)idx,
                                  0.0,
                                  width,
                                  height);
        [(UIView *)obj setFrame:frame];
    }];
}

@end

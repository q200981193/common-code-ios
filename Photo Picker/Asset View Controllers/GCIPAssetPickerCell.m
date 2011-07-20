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

#pragma mark - object methods
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    if (self) {
//        self.selectionStyle = UITableViewCellSelectionStyleNone;
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
    CGFloat height = self.contentView.bounds.size.height - 4.0;
    CGFloat width = self.contentView.bounds.size.width;
    CGFloat columns = (CGFloat)self.numberOfColumns;
    CGFloat occupiedWidth = height * columns;
    CGFloat emptyWidth = width - occupiedWidth;
    CGFloat paddingWidth = emptyWidth / (columns + 1.0);
    [self.contentView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        CGRect frame = CGRectMake(paddingWidth + (paddingWidth + height) * (CGFloat)idx, 0.0, height, height);
        [(UIView *)obj setFrame:frame];
    }];
}

@end

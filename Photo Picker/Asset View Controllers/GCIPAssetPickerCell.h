//
//  GCAssetPickerCell.h
//  QuickShot
//
//  Created by Caleb Davenport on 6/14/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CGFloat GCIPAssetViewPadding;

@interface GCIPAssetPickerCell : UITableViewCell {
@private
    NSUInteger numberOfAssets;
}

+ (NSUInteger)sizeForNumberOfAssetsPerRow:(NSUInteger)count inView:(UIView *)view;

- (id)initWithNumberOfAssets:(NSUInteger)count identifier:(NSString *)identifier;
- (void)setAssets:(NSArray *)assets selected:(NSSet *)selected;

@end

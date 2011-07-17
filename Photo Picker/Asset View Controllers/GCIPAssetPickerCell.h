//
//  GCAssetPickerCell.h
//  QuickShot
//
//  Created by Caleb Davenport on 6/14/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GCIPAssetPickerCell : UITableViewCell {
    
}

// view geometry properties
@property (nonatomic, assign) CGFloat columnPadding;
@property (nonatomic, assign) NSUInteger numberOfColumns;

// calculate the tile size given certain parameters
+ (CGFloat)columnWidthForNumberOfColumns:(NSUInteger)columns withPadding:(CGFloat)padding inView:(UIView *)view;

// set assets to display and pass a set of selected asset urls
- (void)setAssets:(NSArray *)assets selected:(NSSet *)selected;

@end

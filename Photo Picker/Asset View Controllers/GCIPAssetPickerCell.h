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

// number of columns for the cell to display
@property (nonatomic, assign) NSUInteger numberOfColumns;

// set assets to display and pass a set of selected asset urls
- (void)setAssets:(NSArray *)assets selected:(NSSet *)selected;

@end

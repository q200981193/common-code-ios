//
//  GCImageGridCell.h
//  QuickShot
//
//  Created by Caleb Davenport on 4/1/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^GCImageGridCellLayoutBlock) (UIView *view, NSUInteger index);

@interface GCImageGridCell : UITableViewCell {
    
}

@property (nonatomic, copy) GCImageGridCellLayoutBlock layoutBlock;

@end

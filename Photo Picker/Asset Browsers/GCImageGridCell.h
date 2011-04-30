//
//  GCImageGridCell.h
//  GUI Cocoa Common Code Library for iOS
//
//  Created by Caleb Davenport on 4/1/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

// protocol
@class GCImageGridCell;
@protocol GCImageGridCellDelegate <NSObject>
@required
- (void)positionView:(UIView *)view forIndex:(NSUInteger)index;
@end

// class
@interface GCImageGridCell : UITableViewCell {
    
}

@property (nonatomic, assign) id<GCImageGridCellDelegate> delegate;

@end

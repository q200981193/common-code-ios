//
//  GCContentScrollView.h
//  GUI Cocoa Common Code Library for iOS
//
//  Created by Caleb Davenport on 3/27/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GCContentScrollView : UIScrollView <UIScrollViewDelegate> {
    
}

@property (nonatomic, retain) UIView *view;
@property (nonatomic, assign) NSUInteger index;

// designated initializer
- (id)initWithFrame:(CGRect)frame;

// view geometry
- (void)updateZoomLimits;
- (CGPoint)pointToRestoreAfterRotation;
- (CGFloat)scaleToRestoreAfterRotation;
- (void)restorePoint:(CGPoint)point scale:(CGFloat)scale;
- (void)centerView;

@end

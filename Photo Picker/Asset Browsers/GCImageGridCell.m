//
//  GCImageGridCell.m
//  GUI Cocoa Common Code Library for iOS
//
//  Created by Caleb Davenport on 4/1/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import "GCImageGridCell.h"

@implementation GCImageGridCell

@synthesize delegate=_delegate;

- (void)layoutSubviews {
    [super layoutSubviews];
    NSArray *subviews = self.contentView.subviews;
    for (NSUInteger i = 0; i < [subviews count]; i++) {
        UIView *view = [subviews objectAtIndex:i];
        [self.delegate positionView:view forIndex:i];
    }
}

@end

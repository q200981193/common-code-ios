//
//  GCImageGridCell.m
//  QuickShot
//
//  Created by Caleb Davenport on 4/1/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import "GCImageGridCell.h"

@implementation GCImageGridCell

@synthesize layoutBlock=_layoutBlock;

- (void)dealloc {
    self.layoutBlock = nil;
    [super dealloc];
}
- (void)layoutSubviews {
    [super layoutSubviews];
    NSArray *subviews = self.contentView.subviews;
    for (NSUInteger i = 0; i < [subviews count]; i++) {
        self.layoutBlock([subviews objectAtIndex:i], i);
    }
}

@end

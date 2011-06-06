//
//  UIApplication+Activity.h
//  QuickShot
//
//  Created by Caleb Davenport on 6/5/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIApplication (Activity)
- (void)gc_pushActivity;
- (void)gc_popActivity;
@end

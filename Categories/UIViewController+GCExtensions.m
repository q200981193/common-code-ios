//
//  UIViewController+GCExtensions.m
//  QuickShot
//
//  Created by Caleb Davenport on 3/16/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import "UIViewController+GCExtensions.h"

@implementation UIViewController (GCExtensions)

- (BOOL)gc_isRootViewController {
    if (self.navigationController == nil) { return YES; }
    else { return ([[self.navigationController viewControllers] objectAtIndex:0] == self); }
}

@end

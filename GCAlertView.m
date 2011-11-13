/*
 
 Copyright (C) 2011 GUI Cocoa, LLC.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */

#import "GCAlertView.h"

static NSString *GCAlertViewWillPresentKey = @"GCAlertViewWillPresentAction";
static NSString *GCAlertViewDidPresentKey = @"GCAlertViewDidPresentAction";
static NSString *GCAlertViewWillDismissKey = @"GCAlertViewWillDismissAction";
static NSString *GCAlertViewDidDismissKey = @"GCAlertViewDidDismissAction";

@interface GCAlertView ()
@property (nonatomic, retain) NSMutableDictionary *actions;
@end

@implementation GCAlertView

@synthisize actions = __actions;

- (id)initWithTitle:(NSString *)title message:(NSString *)message {
    self = [super initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    if (self) {
        self.actions = [[[NSMutableDictionary alloc] init] autorelease];
    }
    return self;
}
- (void)dealloc {
    self.actions = nil;
    [super dealloc];
}
- (void)addButtonWithTitle:(NSString *)title block:(void (^) (void))block {
    if ([self.actions objectForKey:title]) { return; }
    [self addButtonWithTitle:title];
    if (block) {
        void (^action) () = Block_copy(block);
        [self.actions setObject:action forKey:title];
        Block_release(action);
    }
}
- (void)setWillPresentBlock:(void (^) (void))block {
    if (block) {
        void (^action) () = Block_copy(block);
        [self.actions setObject:action forKey:GCAlertViewWillPresentKey];
        Block_release(action);
    }
    else {
        [self.actions removeObjectForKey:GCAlertViewWillPresentKey];
    }
}
- (void)setDidPresentBlock:(void (^) (void))block {
    if (block) {
        void (^action) () = Block_copy(block);
        [self.actions setObject:action forKey:GCAlertViewDidPresentKey];
        Block_release(action);
    }
    else {
        [self.actions removeObjectForKey:GCAlertViewDidPresentKey];
    }
}
- (void)setWillDismissBlock:(void (^) (void))block {
    if (block) {
        void (^action) () = Block_copy(block);
        [self.actions setObject:action forKey:GCAlertViewWillDismissKey];
        Block_release(action);
    }
    else {
        [self.actions removeObjectForKey:GCAlertViewWillDismissKey];
    }
}
- (void)setDidDismissBlock:(void (^) (void))block {
    if (block) {
        void (^action) () = Block_copy(block);
        [self.actions setObject:action forKey:GCAlertViewDidDismissKey];
        Block_release(action);
    }
    else {
        [self.actions removeObjectForKey:GCAlertViewDidDismissKey];
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex >= 0 && buttonIndex < alertView.numberOfButtons) {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        void (^action) () = [self.actions objectForKey:title];
        if (action) { action(); }
    }
}
- (void)willPresentAlertView:(UIAlertView *)alertView {
    void (^action) () = [self.actions objectForKey:GCAlertViewWillPresentKey];
    if (action) { action(); }
}
- (void)didPresentAlertView:(UIAlertView *)alertView {
    void (^action) () = [self.actions objectForKey:GCAlertViewDidPresentKey];
    if (action) { action(); }
}
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    void (^action) () = [self.actions objectForKey:GCAlertViewWillDismissKey];
    if (action) { action(); }
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    void (^action) () = [self.actions objectForKey:GCAlertViewDidDismissKey];
    if (action) { action(); }
}

@end

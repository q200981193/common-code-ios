//
//  GCTextCell.h
//  GUI Cocoa Common Code Library for iOS
//
//  Created by Caleb Davenport on 4/7/09.
//  Copyright 2009 GUI Cocoa Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GCTextFieldCell : UITableViewCell {
    
}

@property (nonatomic, readonly) UITextField *textField;

- (id)initWithReuseIdentifier:(NSString *)identifier;

@end

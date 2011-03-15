//
//  GCTextCell.m
//  GUI Cocoa Common Code Library for iOS
//
//  Created by Caleb Davenport on 4/7/09.
//  Copyright 2009 GUI Cocoa Software. All rights reserved.
//

#import "GCTextFieldCell.h"

#define kSideOffset 10

@implementation GCTextFieldCell

@synthesize textField;

#pragma mark -
#pragma mark initialize
- (id)initWithReuseIdentifier:(NSString *)identifier {
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
	if (self) {
		// setup text field
		textField = [[UITextField alloc] init];
		textField.backgroundColor = [UIColor clearColor];
		textField.opaque = YES;
		textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		textField.clearButtonMode = UITextFieldViewModeWhileEditing;
		textField.font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
		textField.textAlignment = UITextAlignmentLeft;
		textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
		textField.autocorrectionType = UITextAutocorrectionTypeDefault;
		[self.contentView addSubview:textField];
		[textField release];
		
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.accessoryType = UITableViewCellAccessoryNone;
	}
	
	return self;
}

#pragma mark -
#pragma mark layout
- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGRect content = self.contentView.bounds;
	CGRect rect;
	
	if (self.textLabel.text != nil && [self.textLabel.text length] > 0) {
		
		// field width
		CGFloat fieldWidth = floor(content.size.width * 0.5 - kSideOffset * 0.5);
		if (self.textField.textAlignment == UITextAlignmentRight) {
			fieldWidth -= 2.0;
		}
		rect = CGRectMake(content.size.width * 0.5,
						  0, fieldWidth, content.size.height);
		self.textField.frame = rect;
		
		// text width
		rect = CGRectMake(self.textLabel.frame.origin.x, 0,
						  content.size.width * 0.5 - self.textLabel.frame.origin.x,
						  content.size.height);
		self.textLabel.frame = rect;
		
	}
	else {
		rect = CGRectMake(kSideOffset, 0,
						  content.size.width - kSideOffset - kSideOffset * 0.5,
						  content.size.height);
		textField.frame = rect;
	}
}

@end

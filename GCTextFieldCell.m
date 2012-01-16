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

#import "GCTextFieldCell.h"

@implementation GCTextFieldCell

@synthesize textField = __textField;

#pragma mark - object lifecycle
- (id)initWithReuseIdentifier:(NSString *)identifier {
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
	if (self) {
        
		// setup text field
        UITextField *field = [[[UITextField alloc] initWithFrame:CGRectZero] autorelease];
        field.backgroundColor = [UIColor clearColor];
		field.opaque = YES;
		field.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		field.clearButtonMode = UITextFieldViewModeWhileEditing;
		field.font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
		field.textAlignment = UITextAlignmentLeft;
		field.autocapitalizationType = UITextAutocapitalizationTypeWords;
		field.autocorrectionType = UITextAutocorrectionTypeDefault;
		[self.contentView addSubview:field];
        self.textField = field;
        
		// setup self
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.accessoryType = UITableViewCellAccessoryNone;
        
	}
	
	return self;
}
- (void)dealloc {
    self.textField = nil;
    [super dealloc];
}

#pragma mark - layout
- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect content = self.contentView.bounds;
	CGRect rect;
	if ([self.textLabel.text length]) {
		
		// field width
		CGFloat fieldWidth = floor(content.size.width * 0.5 - 10.0 * 0.5);
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
		rect = CGRectMake(10.0, 0,
						  content.size.width - 10.0 - 10.0 * 0.5,
						  content.size.height);
		self.textField.frame = rect;
	}
}

@end

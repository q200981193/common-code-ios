//
//  GCSwitchCell.m
//  GUI Cocoa Common Code Library
//
//  Created by Caleb Davenport on 3/31/09.
//  Copyright 2009 GUI Cocoa Software. All rights reserved.
//

#import "GCSwitchCell.h"

@implementation GCSwitchCell

@synthesize cellSwitch=_cellSwitch;

#pragma mark -
#pragma mark initialize
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier {
	self = [super initWithStyle:style reuseIdentifier:identifier];
	if (self) {
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.accessoryType = UITableViewCellAccessoryNone;
		_cellSwitch = [[UISwitch alloc] init];
		self.accessoryView = _cellSwitch;
		[_cellSwitch release];
	}
	return self;
}

@end

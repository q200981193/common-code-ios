//
//	GCSwitchCell.h
//  GUI Cocoa Common Code Library
//
//  Created by Caleb Davenport on 3/31/09.
//  Copyright 2009 GUI Cocoa Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GCSwitchCell : UITableViewCell {
@private
	UISwitch *_cellSwitch;
}

@property (nonatomic, readonly) UISwitch *cellSwitch;

@end

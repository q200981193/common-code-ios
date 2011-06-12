//
//  ALAssetsLibrary+CustomAccessors.h
//  QuickShot
//
//  Created by Caleb Davenport on 6/11/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

@interface ALAssetsLibrary (CustomAccessors)


/*
 get assets groups sorted the same as seen in UIImagePickerController
 
 types: filter group types. pass ALAssetGroupAll for all groups.
 filter: filter the types of assets shown. groups with no assets
    matching the filter will be omitted
 error: will be populated if no groups can be loaded
 
 returns: an array of groups
 */
- (NSArray *)assetGroupsWithTypes:(ALAssetsGroupType)types assetsFilter:(ALAssetsFilter *)filter error:(NSError **)error;

@end

//
//  ALAssetsLibrary+CustomAccessors.m
//  QuickShot
//
//  Created by Caleb Davenport on 6/11/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import "ALAssetsLibrary+CustomAccessors.h"

@implementation ALAssetsLibrary (CustomAccessors)
- (NSArray *)assetGroupsWithTypes:(ALAssetsGroupType)types assetsFilter:(ALAssetsFilter *)filter error:(NSError **)error {
    
    // this will be returned
    __block NSMutableArray *groups = nil;
    
    // load groups
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [self
     enumerateGroupsWithTypes:types
     usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
         if (group == nil) {
             
             // make our groups array
             groups = [[NSMutableArray alloc] init];
             
             // sort groups into final container
             NSArray *typeNumbers = [NSArray arrayWithObjects:
                                     [NSNumber numberWithUnsignedInteger:ALAssetsGroupSavedPhotos],
                                     [NSNumber numberWithUnsignedInteger:ALAssetsGroupAlbum],
                                     [NSNumber numberWithUnsignedInteger:ALAssetsGroupEvent],
                                     [NSNumber numberWithUnsignedInteger:ALAssetsGroupFaces],
                                     nil];
             for (NSNumber *type in typeNumbers) {
                 NSArray *groupsByType = [dictionary objectForKey:type];
                 [groups addObjectsFromArray:groupsByType];
                 [dictionary removeObjectForKey:type];
             }
             
             // get any groups we do not have contants for
             for (NSNumber *type in [dictionary keysSortedByValueUsingSelector:@selector(compare:)]) {
                 NSArray *groupsByType = [dictionary objectForKey:type];
                 [groups addObjectsFromArray:groupsByType];
                 [dictionary removeObjectForKey:type];
             }
             
         }
         else {
             [group setAssetsFilter:filter];
             if ([group numberOfAssets]) {
                 NSNumber *type = [group valueForProperty:ALAssetsGroupPropertyType];
                 NSMutableArray *groupsByType = [dictionary objectForKey:type];
                 if (groupsByType == nil) {
                     groupsByType = [NSMutableArray arrayWithCapacity:1];
                     [dictionary setObject:groupsByType forKey:type];
                 }
                 [groupsByType addObject:group];
             }
         }
     }
     failureBlock:^(NSError *failure) {
         if (error != nil) {
             *error = failure;
         }
         groups = [[NSArray alloc] init];
     }];
    
    // wait
    while (groups == nil) {
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.1, NO);
    }
        
    // return
    return [groups autorelease];
    
}
@end

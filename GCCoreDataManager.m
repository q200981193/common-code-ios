//
//  QSDataManager.m
//  QuickShot
//
//  Created by Caleb Davenport on 9/9/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import <CoreData/CoreData.h>

#import "GCCoreDataManager.h"

static NSPersistentStoreCoordinator *coordinator = nil;

@implementation GCCoreDataManager

+ (void)initializeWithFileName:(NSString *)name {
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
        coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        NSURL *URL = [[[NSFileManager defaultManager]
                       URLsForDirectory:NSDocumentDirectory
                       inDomains:NSUserDomainMask]
                      objectAtIndex:0];
        URL = [URL URLByAppendingPathComponent:(name ?: @"database.db")];
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                                 nil];
        NSError *error = nil;
        if (![coordinator
              addPersistentStoreWithType:NSSQLiteStoreType
              configuration:nil
              URL:URL
              options:options
              error:&error]) {
            // uh oh
        }
    });
}
+ (NSManagedObjectContext *)context {
    NSAssert(coordinator, @"Please call `initializeWithFileName:` to setup the core data manager");
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    [context setPersistentStoreCoordinator:coordinator];
    return [context autorelease];
}

@end

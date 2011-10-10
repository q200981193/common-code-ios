//
//  QSDataManager.h
//  QuickShot
//
//  Created by Caleb Davenport on 9/9/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSManagedObjectContext;

@interface GCCoreDataManager : NSObject

/*
 Start the core data stack given a database file name. The file will be placed
 in the application's Documents directory. The persistent store will be setup
 with a suite of default options. If you pass `nil` in for the name, 
 "database.db" will be used.
 */
+ (void)initializeWithFileName:(NSString *)name;

/*
 Get a new managed object context.
 */
+ (NSManagedObjectContext *)context;

@end

//
//  GCManagedObject.h
//  GUI Cocoa Common Code Library for iOS
//
//  Created by Caleb Davenport on 3/10/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface GCManagedObject : NSManagedObject

@property (nonatomic, retain) NSDate *createdAt;

// default context
+ (void)setDefaultContext:(NSManagedObjectContext *)context;
+ (NSManagedObjectContext *)defaultContext;

// create object in default context
+ (id)instance;

// create object in specified context
+ (id)instanceInContext:(NSManagedObjectContext *)context;

// find objects in default context
+ (NSArray *)all;
+ (NSArray *)allWithSortDescriptor:(NSSortDescriptor *)descriptor;
+ (NSArray *)allWithSortDescriptors:(NSArray *)descriptors;
+ (NSArray *)allWithPredicate:(NSPredicate *)predicate;
+ (NSArray *)allWithPredicate:(NSPredicate *)predicate sortDescriptor:(NSSortDescriptor *)descriptor;
+ (NSArray *)allWithPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)descriptors;

// find objects in specified context
+ (NSArray *)allInContext:(NSManagedObjectContext *)context;
+ (NSArray *)allInContext:(NSManagedObjectContext *)context sortDescriptor:(NSSortDescriptor *)descriptor;
+ (NSArray *)allInContext:(NSManagedObjectContext *)context sortDescriptors:(NSArray *)descriptors;
+ (NSArray *)allInContext:(NSManagedObjectContext *)context withPredicate:(NSPredicate *)predicate;
+ (NSArray *)allInContext:(NSManagedObjectContext *)context withPredicate:(NSPredicate *)predicate sortDescriptor:(NSSortDescriptor *)descriptor;
+ (NSArray *)allInContext:(NSManagedObjectContext *)context withPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)descriptors;

// count objects in default context
+ (NSUInteger)count;
+ (NSUInteger)countWithPredicate:(NSPredicate *)predicate;

// count objects in specified context
+ (NSUInteger)countInContext:(NSManagedObjectContext *)context;
+ (NSUInteger)countInContext:(NSManagedObjectContext *)context withPredicate:(NSPredicate *)predicate;

// delete object
- (void)destroy;

@end

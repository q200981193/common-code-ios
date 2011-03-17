//
//  GCManagedObject.m
//  GUI Cocoa Common Code Library for iOS
//
//  Created by Caleb Davenport on 3/10/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import "GCManagedObject.h"

@implementation GCManagedObject

#pragma mark - entity description
+ (NSEntityDescription *)entityDescriptionInContext:(NSManagedObjectContext *)context {
    NSString *className = NSStringFromClass(self);
    return [NSEntityDescription entityForName:className inManagedObjectContext:context];
}

#pragma mark - create objects
+ (id)instanceInContext:(NSManagedObjectContext *)context {
    NSString *className = NSStringFromClass(self);
    return [NSEntityDescription insertNewObjectForEntityForName:className inManagedObjectContext:context];
}

#pragma mark - find objects
+ (NSArray *)allInContext:(NSManagedObjectContext *)context {
    return [self allInContext:context withPredicate:nil sortDescriptors:nil];
}
+ (NSArray *)allInContext:(NSManagedObjectContext *)context sortDescriptor:(NSSortDescriptor *)descriptor {
    return [self allInContext:context withPredicate:nil sortDescriptor:descriptor];
}
+ (NSArray *)allInContext:(NSManagedObjectContext *)context sortDescriptors:(NSArray *)descriptors {
    return [self allInContext:context withPredicate:nil sortDescriptors:descriptors];
}
+ (NSArray *)allInContext:(NSManagedObjectContext *)context withPredicate:(NSPredicate *)predicate {
    return [self allInContext:context withPredicate:predicate sortDescriptors:nil];
}
+ (NSArray *)allInContext:(NSManagedObjectContext *)context withPredicate:(NSPredicate *)predicate sortDescriptor:(NSSortDescriptor *)descriptor {
    return [self allInContext:context withPredicate:predicate sortDescriptors:[NSArray arrayWithObject:descriptor]];
}
+ (NSArray *)allInContext:(NSManagedObjectContext *)context withPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)descriptors {
    NSString *className = NSStringFromClass(self);
    NSEntityDescription *entity = [NSEntityDescription entityForName:className inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    if (descriptors) {
        [request setSortDescriptors:descriptors];
    }
    if (predicate) {
        [request setPredicate:predicate];
    }
    NSArray *matching = [context executeFetchRequest:request error:nil];
    [request release];
    return matching;
}

#pragma mark - count objects
+ (NSUInteger)countInContext:(NSManagedObjectContext *)context {
    return [self countInContext:context withPredicate:nil];
}
+ (NSUInteger)countInContext:(NSManagedObjectContext *)context withPredicate:(NSPredicate *)predicate {
    NSString *className = NSStringFromClass(self);
    NSEntityDescription *entity = [NSEntityDescription entityForName:className inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    if (predicate) {
        [request setPredicate:predicate];
    }
    NSUInteger count = [context countForFetchRequest:request error:nil];
    [request release];
    return count;
}

#pragma mark delete objects
- (void)destroy {
    NSManagedObjectContext *context = [self managedObjectContext];
    [context deleteObject:self];
}
- (void)destroyAndSave {
    NSManagedObjectContext *context = [self managedObjectContext];
    [context deleteObject:self];
    [context save:nil];
}

@end

#endif

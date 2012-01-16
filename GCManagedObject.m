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

#import "GCManagedObject.h"

static NSManagedObjectContext *__context = nil;

@implementation GCManagedObject

@dynamic createdAt;

#pragma mark - default context
+ (void)setDefaultContext:(NSManagedObjectContext *)context {
    @synchronized(self) {
        [__context release];
        __context = [context retain];
    }
}
+ (NSManagedObjectContext *)defaultContext {
    @synchronized(self) {
        return __context;
    }    
}

#pragma mark - custom model name
+ (NSString *)modelName {
  return NSStringFromClass(self);
}

#pragma mark - create objects
+ (id)instance {
    return [self instanceInContext:[self defaultContext]];
}
+ (id)instanceInContext:(NSManagedObjectContext *)context {
    NSString *name = [self modelName];
    id instance = [NSEntityDescription insertNewObjectForEntityForName:name inManagedObjectContext:context];
    [(GCManagedObject *)instance setCreatedAt:[NSDate date]];
    return instance;
}

#pragma mark - fetch request
+ (NSFetchRequest *)fetchRequest {
    return [self fetchRequestInContext:[self defaultContext]];
}
+ (NSFetchRequest *)fetchRequestInContext:(NSManagedObjectContext *)context {
    NSString *name = [self modelName];
    NSEntityDescription *entity = [NSEntityDescription entityForName:name inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    return [request autorelease];
}

#pragma mark - find objects
+ (NSArray *)all {
    return [self allInContext:[self defaultContext]];
}
+ (NSArray *)allWithSortDescriptor:(NSSortDescriptor *)descriptor {
    return [self allInContext:[self defaultContext] sortDescriptor:descriptor];
}
+ (NSArray *)allWithSortDescriptors:(NSArray *)descriptors {
    return [self allInContext:[self defaultContext] sortDescriptors:descriptors];
}
+ (NSArray *)allWithPredicate:(NSPredicate *)predicate {
    return [self allInContext:[self defaultContext] withPredicate:predicate];
}
+ (NSArray *)allWithPredicate:(NSPredicate *)predicate sortDescriptor:(NSSortDescriptor *)descriptor {
    return [self allInContext:[self defaultContext] withPredicate:predicate sortDescriptor:descriptor];
}
+ (NSArray *)allWithPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)descriptors {
    return [self allInContext:[self defaultContext] withPredicate:predicate sortDescriptors:descriptors];    
}
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
    NSFetchRequest *request = [self fetchRequestInContext:context];
    if (descriptors) {
        [request setSortDescriptors:descriptors];
    }
    if (predicate) {
        [request setPredicate:predicate];
    }
    return [context executeFetchRequest:request error:nil];
}

#pragma mark - count objects
+ (NSUInteger)count {
    return [self countInContext:[self defaultContext]];
}
+ (NSUInteger)countWithPredicate:(NSPredicate *)predicate {
    return [self countInContext:[self defaultContext] withPredicate:predicate];
}
+ (NSUInteger)countInContext:(NSManagedObjectContext *)context {
    return [self countInContext:context withPredicate:nil];
}
+ (NSUInteger)countInContext:(NSManagedObjectContext *)context withPredicate:(NSPredicate *)predicate {
    NSFetchRequest *request = [self fetchRequestInContext:context];
    if (predicate) {
        [request setPredicate:predicate];
    }
    return [context countForFetchRequest:request error:nil];
}

@end
